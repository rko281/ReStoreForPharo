"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBCollectionIndexUpdate,
	#superclass : #SSWDBCollectionChange,
	#instVars : [
		'newIndex'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #'instance creation' }
SSWDBCollectionIndexUpdate class >> entry: aCollectionEntry newIndex: anInteger [

	^(self newWithEntry: aCollectionEntry)
		newIndex: anInteger;
		yourself
]

{ #category : #'actions - api' }
SSWDBCollectionIndexUpdate >> applyTo: aCollection [

	self affectedEntry index: self newIndex

"	| oldIndex |

	oldIndex := aCollection identityIndexOf: self affectedEntry.
	oldIndex = newIndex ifFalse: 
		[aCollection 
			removeAtIndex: oldIndex;
			add: self affectedEntry afterIndex: (self newIndex - 1)]"
]

{ #category : #'actions - api' }
SSWDBCollectionIndexUpdate >> commitFor: aCollectionProxy [

	self affectedEntry isPersistent ifTrue: 
		[aCollectionProxy _collectionSpec 
			updateEntry: self affectedEntry 
			withIndex: self newIndex
			in: aCollectionProxy _reStore]
]

{ #category : #accessing }
SSWDBCollectionIndexUpdate >> newIndex [

	"newIndex stores the Integer index which the entry represented by the receiver
	should hold on commit"

	^newIndex
]

{ #category : #accessing }
SSWDBCollectionIndexUpdate >> newIndex: anInteger [

	"newIndex stores the Integer index which the entry represented by the receiver
	should hold on commit"

	newIndex := anInteger
]

{ #category : #accessing }
SSWDBCollectionIndexUpdate >> oldIndex [

	^self affectedEntry index
]

{ #category : #'actions - api' }
SSWDBCollectionIndexUpdate >> prepareToCommitFor: anSSWDBCollectionProxy [

	self newIndex _ensureActiveIn: anSSWDBCollectionProxy _reStore.

	^super prepareToCommitFor: anSSWDBCollectionProxy
]
