"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLUpdateObjectQuery,
	#superclass : #SSWSQLObjectQuery,
	#instVars : [
		'fieldUpdates'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #'instance creation' }
SSWSQLUpdateObjectQuery class >> forObject: aProxydObject withUpdates: anSSWSQLCollection [

	^(super forObject: aProxydObject)
		fieldUpdates: anSSWSQLCollection;
		yourself
]

{ #category : #accessing }
SSWSQLUpdateObjectQuery >> fieldUpdates [

	"fieldUpdates stores an SSWSQLFieldCollection of SSWSQLConditions that
	define the updates to be written by the receiver"
	
	^fieldUpdates
]

{ #category : #accessing }
SSWSQLUpdateObjectQuery >> fieldUpdates: anSSWSQLFieldCollection [ 

	"fieldUpdates stores an SSWSQLFieldCollection of SSWSQLConditions that
	define the updates to be written by the receiver"
	
	fieldUpdates := anSSWSQLFieldCollection 
]

{ #category : #accessing }
SSWSQLUpdateObjectQuery >> parameterisedFields [

	"UPDATE table SET updatedFields TO updatedValues WHERE objectIDCondition AND objectControlConditions"

	^self updatedFields
		add: self table idField;
		addAll: (self table controlFields reject: [ :each | (each accessor valueIn: self object) isNil]);
		yourself
]

{ #category : #accessing }
SSWSQLUpdateObjectQuery >> updatedFields [

	| updatedFields |

	updatedFields := SSWSQLFieldCollection new: (self fieldUpdates size + 2).

	self fieldUpdates do: [ :each | updatedFields add: each field].

	^updatedFields
]

{ #category : #accessing }
SSWSQLUpdateObjectQuery >> updatedValues [

	| updatedValues |

	updatedValues := SSWSQLFieldCollection new: (self fieldUpdates size + 2).

	self fieldUpdates do: [ :each | updatedValues add: each value].

	^updatedValues
]

{ #category : #accessing }
SSWSQLUpdateObjectQuery >> values [

	"UPDATE table SET updatedFields TO updatedValues WHERE objectIDCondition AND objectControlConditions"

	| parameterisedValues |

	parameterisedValues := self updatedValues.

	parameterisedValues add: self object _id.
	self objectControlConditions do: [ :each | each value ifNotNil: [ :value | parameterisedValues add: value]].

	^parameterisedValues
]

{ #category : #output }
SSWSQLUpdateObjectQuery >> writeSQLOn: aStream [

	aStream nextPutAll: 'UPDATE '.
	self table writeSQLOn: aStream.
	
	aStream nextPutAll: ' SET '.
	self fieldUpdates writeSQLOn: aStream.
	
	aStream nextPutAll: ' WHERE '.
	(self objectIDCondition sqlAnd: self objectControlConditions) writeSQLOn: aStream
]
