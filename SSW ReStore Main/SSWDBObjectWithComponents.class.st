"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBObjectWithComponents,
	#superclass : #SSWDBWrapper,
	#instVars : [
		'exclusions'
	],
	#category : #'SSW ReStore Main'
}

{ #category : #'instance creation' }
SSWDBObjectWithComponents class >> new [

	^super new
		exclusions: IdentitySet new;
		yourself
]

{ #category : #testing }
SSWDBObjectWithComponents >> _changedObjectsIn: aReStore [

	| allChanged |

	allChanged := IdentitySet new.

	self withComponentsIn: aReStore do: [ :each | (each _checkHasChangedIn: aReStore) ifTrue: [allChanged add: each]].

	^allChanged
]

{ #category : #testing }
SSWDBObjectWithComponents >> _checkHasChangedIn: aReStore [

	"true if either the object itself has changed, or any of its components (or their components, recursively) have changed"

	self withComponentsIn: aReStore do: [ :each | (each _checkHasChangedIn: aReStore) ifTrue: [^true]].

	^false
]

{ #category : #actions }
SSWDBObjectWithComponents >> _commitIn: aReStore [

	self withComponentsIn: aReStore do: [ :each | each _commitIn: aReStore]
]

{ #category : #actions }
SSWDBObjectWithComponents >> _forceRefreshIn: aReStore [

	self _refreshIn: aReStore with: [ :obj | obj _forceRefreshWithContents]
]

{ #category : #actions }
SSWDBObjectWithComponents >> _lazyRefreshIn: aReStore [

	| all |

	"Lazy refresh is basically forgetting the objects so we need to accumulate all items first"
	all := IdentitySet new.
	self withComponentsIn: aReStore do: [ :each | all add: each].

	all do: [ :each | each _lazyRefreshIn: aReStore]
]

{ #category : #actions }
SSWDBObjectWithComponents >> _refreshIfUpdatedIn: aReStore [

	self _refreshIn: aReStore with: [ :obj | obj _refreshWithContentsIfUpdated]
]

{ #category : #actions }
SSWDBObjectWithComponents >> _refreshIn: aReStore [

	self _refreshIn: aReStore with: [ :obj | obj _refreshWithContents]
]

{ #category : #actions }
SSWDBObjectWithComponents >> _refreshIn: aReStore with: aBlock [

	"Private - Refresh objects represented by the receiver by evaluating each one with aBlock. Each evaluation should return a collection of refreshed objects"

	| all evaluated |

	"Refresh happens immediately so may cause some items to be skipped; examples: 
	 - item added to collection in this session; refresh of collection removes it
	 - item removed from collection in other session; refresh removes it in this session 
	To prevent these objects being skipped we first accumulate all items"
	all := IdentitySet new.
	self withComponentsIn: aReStore do: [ :each | all add: each].

	evaluated := self exclusions copy.
	self withComponentsIn: aReStore do: aBlock visited: self exclusions copy evaluated: evaluated.

	"Now refresh any skipped items"
	all do: [ :each | (evaluated includes: each) ifFalse: [evaluated addAll: (aBlock value: each)]]
]

{ #category : #actions }
SSWDBObjectWithComponents >> _rollbackIn: aReStore [

	self withComponentsIn: aReStore do: [ :each | each _rollbackIn: aReStore]
]

{ #category : #enumerating }
SSWDBObjectWithComponents >> componentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet [

	(aReStore tableForClass: self object class ifAbsent: [nil]) ifNotNil: 
		[ :table |
		table componentsDo: 
			[ :component |
			component componentsOf: self object do: 
				[ :each | 
				each withComponents withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]]]
]

{ #category : #accessing }
SSWDBObjectWithComponents >> exclusions [
	^exclusions
]

{ #category : #accessing }
SSWDBObjectWithComponents >> exclusions: anObject [
	exclusions := anObject
]

{ #category : #accessing }
SSWDBObjectWithComponents >> withComponents [

	^self
]

{ #category : #enumerating }
SSWDBObjectWithComponents >> withComponentsIn: aReStore do: aBlock [

	self withComponentsIn: aReStore do: aBlock visited: self exclusions copy evaluated: IdentitySet new
]

{ #category : #enumerating }
SSWDBObjectWithComponents >> withComponentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet [

	(self object isNil or: [visitedSet includes: self object]) ifTrue: [^self].
	visitedSet add: self object.

	(evaluatedSet includes: self object) ifFalse: 
		[evaluatedSet add: self object.
		aBlock value: self object].

	self object _isRecovered ifTrue: [self componentsIn: aReStore do: aBlock visited: visitedSet evaluated: evaluatedSet]
]

{ #category : #initializing }
SSWDBObjectWithComponents >> without: anObject [

	"Exclude anObject from the components of the receiver's object that will be traversed by the receiver"

	self exclusions add: anObject.
	^self
]

{ #category : #initializing }
SSWDBObjectWithComponents >> withoutAll: aCollection [

	"Exclude all elements of aCollection from the components of the receiver's object that will be traversed by the receiver"

	self exclusions addAll: aCollection.
	^self
]
