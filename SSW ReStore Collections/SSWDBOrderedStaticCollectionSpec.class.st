"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBOrderedStaticCollectionSpec',
	#superclass : 'SSWDBKeyedStaticCollectionSpec',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'accessing:derived' }
SSWDBOrderedStaticCollectionSpec >> dbInstancesFor: aCollectionProxy [

	"Add the ordering"

	| instances |

	instances := super dbInstancesFor: aCollectionProxy.
	instances parser orderingSpecs: (Array with: (SSWDBOrderingSpec ascending: (self collectionTable fieldAccessing: #index))).

	^instances
]

{ #category : 'initialize/release' }
SSWDBOrderedStaticCollectionSpec >> freePreparedStatements [

	updateTargetStatement notNil ifTrue: 
		[updateTargetStatement free.
		updateTargetStatement := nil].

	super freePreparedStatements
]

{ #category : 'constants' }
SSWDBOrderedStaticCollectionSpec >> queryClass [

	"Return the class of select query appropriate for the receiver"
	
	^SSWSQLOrderedSelectQuery
]

{ #category : 'accessing:derived' }
SSWDBOrderedStaticCollectionSpec >> selectQueryIn: anSSWReStore [

	"Always SELECT in ascending order"
	
	^(super selectQueryIn: anSSWReStore)
		orderAscendingBy: (self collectionTable fieldAccessing: #index);
		yourself
]

{ #category : 'actions - api' }
SSWDBOrderedStaticCollectionSpec >> updateEntry: anSSWDBCollectionEntry withTarget: aProxy in: anSSWReStore [ 

	| query |

	query := SSWSQLUpdateObjectQuery 
			forObject: anSSWDBCollectionEntry
			withUpdates: 
				(SSWSQLFieldAssignmentCollection with:
					(SSWSQLFieldAssignment 
						field: self targetField
						value: aProxy)).

	(updateTargetStatement ifNil: [updateTargetStatement := anSSWReStore prepareStatementForQuery: query])
		values: query values;
		exec
]
