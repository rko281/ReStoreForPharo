"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStorePersonTest',
	#superclass : 'SSWReStoreTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStorePersonTest class >> isAbstract [

	^self == SSWReStorePersonTest
]

{ #category : 'Running' }
SSWReStorePersonTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.
	aReStore
		addClass: SimplePerson;
		addClass: SuperPerson;
		addClass: DetailedPerson;
		addClass: SimpleAddress
]
