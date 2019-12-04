"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBKeyedStaticCollectionSpec,
	#superclass : #SSWDBStaticCollectionSpec,
	#instVars : [
		'indexField',
		'updateIndexStatement'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #constants }
SSWDBKeyedStaticCollectionSpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBKeyedCollectionEntry
]

{ #category : #'initialize/release' }
SSWDBKeyedStaticCollectionSpec >> freePreparedStatements [

	updateIndexStatement notNil ifTrue: 
		[updateIndexStatement free.
		updateIndexStatement := nil].

	super freePreparedStatements
]

{ #category : #accessing }
SSWDBKeyedStaticCollectionSpec >> indexField [

	"indexField stores the SSWDBField in the receiver's collectionTable
	that holds the index of the elements"
	
	indexField == nil ifTrue: [indexField := self collectionTable fieldAccessing: #index].
	
	^indexField
]

{ #category : #accessing }
SSWDBKeyedStaticCollectionSpec >> indexField: anSSWDBField [

	"indexField stores the SSWDBField in the receiver's collectionTable
	that holds the index of the elements"
	
	indexField := anSSWDBField
]

{ #category : #'actions - api' }
SSWDBKeyedStaticCollectionSpec >> updateEntry: anSSWDBCollectionEntry withIndex: anInteger in: anSSWReStore [ 

	| query |

	query := SSWSQLUpdateObjectQuery 
			forObject: anSSWDBCollectionEntry
			withUpdates: 
				(SSWSQLFieldAssignmentCollection with:
					(SSWSQLFieldAssignment 
						field: self indexField
						value: anInteger)).

	(updateIndexStatement ifNil: [updateIndexStatement := anSSWReStore prepareStatementForQuery: query])
		values: query values;
		exec
]
