"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBBlockReceiver,
	#superclass : #SSWDBBlockArgument,
	#instVars : [
		'currentTable',
		'path'
	],
	#category : #'SSW ReStore Querying'
}

{ #category : #accessing }
SSWDBBlockReceiver >> _id [

	"Query on the ID field of the receiver's currentTable. 
	Explicitly set the receiver's finalField to be the join field leading to the table; this will pop the joined table if it is not otherwise required"

	self finalField: self finalField
]

{ #category : #accessing }
SSWDBBlockReceiver >> currentTable [

	^currentTable
]

{ #category : #accessing }
SSWDBBlockReceiver >> currentTable: anSSWDBTable [

	currentTable := anSSWDBTable
]

{ #category : #accessing }
SSWDBBlockReceiver >> finalField [

	"If the receiver is parsing a comparison on a joining field (rather than a plain text/number etc.) then finalField will not have been set"
		
	| finalField |

	self hasFinalField ifTrue: [^super finalField].
	
	"Must be comparison on a joining field - use it as the finalField"
	finalField := self parser lastFieldEncounterFor: self.

	"If this is the first encounter with this field then it is not required for a join - remove it.
	Since it is the first encounter then it must by definition be responsible for the last (most recent) join"
	(self parser fieldEncountersWith: finalField) = 1 ifTrue: 
		[self parser referencedTables removeLast.
		self parser removeFieldEncountersWith: finalField].

	^SSWDBQueryTableField forField: finalField in: finalField table
]

{ #category : #'parsing - internal' }
SSWDBBlockReceiver >> forModify [

	^self
]

{ #category : #helpers }
SSWDBBlockReceiver >> newReceiverFor: aField [

	^super newReceiverFor: (self queryFieldFor: aField)
]

{ #category : #accessing }
SSWDBBlockReceiver >> path [
	^path
]

{ #category : #accessing }
SSWDBBlockReceiver >> path: anObject [
	path := anObject
]
