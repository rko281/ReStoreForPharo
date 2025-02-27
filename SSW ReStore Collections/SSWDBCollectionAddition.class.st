"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBCollectionAddition',
	#superclass : 'SSWDBCollectionChange',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'instance creation' }
SSWDBCollectionAddition class >> added: anObject at: keyObject [

	^self newWithEntry:
		(SSWDBKeyedCollectionEntry new
			target: anObject;
			index: keyObject;
			yourself)
]

{ #category : 'actions' }
SSWDBCollectionAddition >> applyTo: aCollection [

	self affectedEntry addTo: aCollection
]

{ #category : 'actions' }
SSWDBCollectionAddition >> commitFor: aCollectionProxy [

	"	self affectedEntry target isNil
		ifTrue: [self affectedEntry targetID: nil]
		ifFalse: [self affectedEntry targetID: self affectedEntry target _id]."

	aCollectionProxy _collectionSpec insertEntry: self affectedEntry
]

{ #category : 'actions' }
SSWDBCollectionAddition >> prepareToCommitFor: aCollectionProxy [

	| table |

	super prepareToCommitFor: aCollectionProxy.

	self affectedEntry target _ensurePersistentIn: aCollectionProxy _reStore.

	table := aCollectionProxy _collectionSpec collectionTable.

	self affectedEntry 
		table: table;
		sourceID: aCollectionProxy _ownerID;
		entryID: (aCollectionProxy _reStore allocateIDFor: self affectedEntry in: table)
]
