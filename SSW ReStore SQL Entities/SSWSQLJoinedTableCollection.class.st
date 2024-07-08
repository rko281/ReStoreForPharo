"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLJoinedTableCollection',
	#superclass : 'SSWSQLTableCollection',
	#type : 'variable',
	#instVars : [
		'joinConditions'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'instance creation' }
SSWSQLJoinedTableCollection class >> new [

	^super new
		joinConditions: SSWSQLConditionCollection forAND;
		yourself
]

{ #category : 'instance creation' }
SSWSQLJoinedTableCollection class >> new: aSize [

	^(super new: aSize)
		joinConditions: SSWSQLConditionCollection forAND;
		yourself
]

{ #category : 'adding/removing' }
SSWSQLJoinedTableCollection >> add: anSSWDBTable joinedWith: anSSWSQLCondition [

	"Add the given table joined with the given condition; return the table added.
	Duplicate entries are permitted - see withoutDuplicates"

	self add: anSSWDBTable. 
	self joinConditions add: anSSWSQLCondition.
	^anSSWDBTable
]

{ #category : 'evaluating' }
SSWSQLJoinedTableCollection >> copy [

	^super copy
		joinConditions: self joinConditions copy;
		yourself
]

{ #category : 'evaluating' }
SSWSQLJoinedTableCollection >> copyEmpty: anInteger [

	^(super copyEmpty: anInteger)
		joinConditions: self joinConditions copy;
		yourself
]

{ #category : 'evaluating' }
SSWSQLJoinedTableCollection >> copyLikeOfSize: anInteger [

	^(super copyLikeOfSize: anInteger)
		joinConditions: self joinConditions copy;
		yourself
]

{ #category : 'enumerating' }
SSWSQLJoinedTableCollection >> doWithJoins: aTwoArgBlock [

	"Iterate over the receiver's *joined* tables, evaluating aTwoArgBlock with each table-join condition pair.
	NB this IGNORES the receiver's first entry (i.e. its soleTable) since this has no matching join condition"
	
	2 to: self size do: [ :index | aTwoArgBlock value: (self at: index) value: (self joinConditions at: (index - 1))]
]

{ #category : 'testing' }
SSWSQLJoinedTableCollection >> hasJoins [

	^self joinConditions size > 0
]

{ #category : 'testing' }
SSWSQLJoinedTableCollection >> includes: anSSWDBTable joinedWith: anSSWSQLCondition [
	
	2 to: self size do:
		[ :index || table join |
		table := self at: index.
		join := self joinConditions at: (index - 1).
		(table = anSSWDBTable and: [join = anSSWSQLCondition]) ifTrue: [^true]].

	^false
]

{ #category : 'accessing' }
SSWSQLJoinedTableCollection >> joinConditions [

	"joinConditions stores a collection of SSWSQLConditions that join the receiver collection of tables.
	e.g. the first table is joined to the second by the first joinCondition, 2>3 by the second etc.
	Hence there should always be one less joinCondition than the size of the receiver"
	
	^joinConditions
]

{ #category : 'accessing' }
SSWSQLJoinedTableCollection >> joinConditions: anOrderedCollection [

	"joinConditions stores a collection of SSWSQLConditions that join the receiver collection of tables.
	e.g. the first table is joined to the second by the first joinCondition, 2>3 by the second etc.
	Hence there should always be one less joinCondition than the size of the receiver"
	
	joinConditions := anOrderedCollection
]

{ #category : 'adding/removing' }
SSWSQLJoinedTableCollection >> merge: anSSWSQLJoinedTableCollection [

	"Add the tables and joins from anSSWSQLJoinedTableCollection to the receiver.
	NB if the receiver is non-empty, this method does *not* add the first (starting) table
	 - this is *assumed* to be the same. 	Also excludes duplicates"
	
	self isEmpty ifTrue: [self addFirst: anSSWSQLJoinedTableCollection first].
	
	anSSWSQLJoinedTableCollection doWithJoins:
		[ :table :joinCondition |
		(self includes: table joinedWith: joinCondition) ifFalse: [self add: table joinedWith: joinCondition]]
]

{ #category : 'adding/removing' }
SSWSQLJoinedTableCollection >> removeLast [

	self joinConditions removeLast. 
	^super removeLast
]

{ #category : 'accessing' }
SSWSQLJoinedTableCollection >> tableJoinedWithField: anSSWDBField [
	
	self joinConditions keysAndValuesDo: [ :index :each | (each value = anSSWDBField and: [each value accessorPath = anSSWDBField accessorPath]) ifTrue: [^self at: (index + 1)]].

	^nil
]

{ #category : 'evaluating' }
SSWSQLJoinedTableCollection >> withoutDuplicates [

	"Return a copy of the receiver, excluding duplicate entries.
	A duplicate entry is defined as the same table joined with the same condition"
	
	| withoutDuplicates |
	
	withoutDuplicates := self copy soleTable: self first.
	
	self doWithJoins:
		[ :table :condition |		
		(withoutDuplicates includes: table joinedWith: condition) ifFalse: [withoutDuplicates add: table joinedWith: condition]].
		
	^withoutDuplicates
]
