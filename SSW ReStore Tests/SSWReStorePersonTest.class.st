"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStorePersonTest,
	#superclass : #SSWReStoreTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStorePersonTest class >> isAbstract [

	^self == SSWReStorePersonTest
]

{ #category : #Running }
SSWReStorePersonTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore
		addClass: SimplePerson;
		addClass: SuperPerson;
		addClass: DetailedPerson;
		addClass: SimpleAddress
]
