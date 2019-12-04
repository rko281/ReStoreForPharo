"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBCollectionEntry,
	#superclass : #Object,
	#instVars : [
		'table',
		'entryID',
		'sourceID',
		'target'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #persistence }
SSWDBCollectionEntry class >> dbTableNamed: aString in: anSSWReStore [

	^(SSWDBTable forClass: self)
		name: aString;
		fullName: aString;
		reStore: anSSWReStore;
		defineAsID: #entryID fieldName: (anSSWReStore sqlDialect transformInstVarName: #id);
		define: #sourceID as: Integer;
		define: #target asFieldNamed: (anSSWReStore sqlDialect transformInstVarName: #targetID) holding: Integer;
		yourself
]

{ #category : #evaluating }
SSWDBCollectionEntry >> _dbTable [

	"Make the receiver polymorphic with a persistent proxy"
	
	^self table
]

{ #category : #evaluating }
SSWDBCollectionEntry >> _id [

	"Make the receiver polymorphic with a persistent proxy"
	
	^self entryID
]

{ #category : #evaluating }
SSWDBCollectionEntry >> _id: anInteger [

	"Make the receiver polymorphic with a persistent proxy"
	
	self entryID: anInteger
]

{ #category : #evaluating }
SSWDBCollectionEntry >> _proxiedObject [

	"Make the receiver polymorphic with a persistent proxy"
	
	^self
]

{ #category : #actions }
SSWDBCollectionEntry >> addTargetTo: aCollection [

	aCollection directAdd: self target
]

{ #category : #actions }
SSWDBCollectionEntry >> addTo: aCollectionOfEntries [

	aCollectionOfEntries add: self
]

{ #category : #accessing }
SSWDBCollectionEntry >> entryID [

	"entryID stores the unique ID of this particular entry object"
	
	^entryID
]

{ #category : #accessing }
SSWDBCollectionEntry >> entryID: anInteger [

	"entryID stores the unique ID of this particular entry object"
	
	entryID := anInteger
]

{ #category : #testing }
SSWDBCollectionEntry >> isPersistent [

	^self entryID ~= nil
]

{ #category : #actions }
SSWDBCollectionEntry >> prepareToCommitFor: anSSWDBCachingCollectionProxy [

	^self
]

{ #category : #actions }
SSWDBCollectionEntry >> removeFrom: aCollectionOfEntries [

	aCollectionOfEntries removeAtIndex: (aCollectionOfEntries identityIndexOf: self)
]

{ #category : #accessing }
SSWDBCollectionEntry >> sourceID [

	"sourceID stores the unique ID of the object which owns the collection 
	of which the receiver represents a member"
	
	^sourceID
]

{ #category : #accessing }
SSWDBCollectionEntry >> sourceID: anInteger [

	"sourceID stores the unique ID of the object which owns the collection 
	of which the receiver represents a member"
	
	sourceID := anInteger
]

{ #category : #accessing }
SSWDBCollectionEntry >> table [

	"table stores the SSWDBTable of collection entries which the receiver belongs to"
	
	^table
]

{ #category : #accessing }
SSWDBCollectionEntry >> table: anSSWDBTable [

	"table stores the SSWDBTable of collection entries which the receiver belongs to"
	
	table := anSSWDBTable
]

{ #category : #accessing }
SSWDBCollectionEntry >> target [

	^target
]

{ #category : #accessing }
SSWDBCollectionEntry >> target: anObjectOrNil [

	"Set the target object of the receiver"
	
	target := anObjectOrNil
]
