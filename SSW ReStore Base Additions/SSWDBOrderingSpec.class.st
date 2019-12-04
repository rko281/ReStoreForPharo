"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBOrderingSpec,
	#superclass : #Object,
	#instVars : [
		'criteria',
		'isAscending'
	],
	#category : #'SSW ReStore Base Additions'
}

{ #category : #'instance creation' }
SSWDBOrderingSpec class >> ascending: anObject [

	^self new
		criteria: anObject;
		isAscending: true;
		yourself
]

{ #category : #'instance creation' }
SSWDBOrderingSpec class >> descending: anObject [

	^self new
		criteria: anObject;
		isAscending: false;
		yourself
]

{ #category : #comparing }
SSWDBOrderingSpec >> compare: objectA with: objectB [

	"Use the receiver to compare the two objects.
	Return true or false, or nil if the two are equal.
	ASSERT: the receiver's criteria is a perform'able message name for both objects"

	| a b |

	a := objectA perform: self criteria.
	b := objectB perform: self criteria.

	^a = b
	ifTrue: 
		[nil]
	ifFalse:
		[self isAscending
			ifTrue: [a <= b]
			ifFalse: [a > b]]
]

{ #category : #accessing }
SSWDBOrderingSpec >> criteria [

	"criteria stores an Object used for ordering
	(the class of Object is dependent on the client of the receiver).
	The direction of ordering is given by isAscending"
	
	^criteria
]

{ #category : #accessing }
SSWDBOrderingSpec >> criteria: anOrderedCollection [

	"criteria stores an Object used for ordering
	(the class of Object is dependent on the client of the receiver).
	The direction of ordering is given by isAscending"
	
	criteria := anOrderedCollection
]

{ #category : #accessing }
SSWDBOrderingSpec >> isAscending [

	"isAscending stores a Boolean indicating if ordering by the receiver's criteria
	should be ascending (true) or descending (false)"
	
	^isAscending
]

{ #category : #accessing }
SSWDBOrderingSpec >> isAscending: aBoolean [

	"isAscending stores a Boolean indicating if ordering by the receiver's criteria
	should be ascending (true) or descending (false)"
	
	isAscending := aBoolean
]
