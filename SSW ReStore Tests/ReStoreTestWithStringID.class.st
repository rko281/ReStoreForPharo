Class {
	#name : #ReStoreTestWithStringID,
	#superclass : #ReStoreTestWithID,
	#classInstVars : [
		'counter'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
ReStoreTestWithStringID class >> counter [

	^ counter
]

{ #category : #accessing }
ReStoreTestWithStringID class >> counter: anObject [

	counter := anObject
]

{ #category : #public }
ReStoreTestWithStringID class >> reStoreDefinition [

	^(SSWDBClassDefinition forClass: self)
		defineAsID: #name;
		define: #nmbr as: Integer;
		define: #other as: ReStoreTestWithStringID;
		yourself
]

{ #category : #public }
ReStoreTestWithStringID class >> reStoreIDClass [

	^String maxSize: 32
]

{ #category : #persistence }
ReStoreTestWithStringID >> reStoreNewUniqueID [

	self class counter: self class counter + 1.
	^'new ', self class counter printString
]
