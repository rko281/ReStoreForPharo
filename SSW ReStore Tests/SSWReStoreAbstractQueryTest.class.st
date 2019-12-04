"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreAbstractQueryTest,
	#superclass : #SSWReStorePersonTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreAbstractQueryTest class >> isAbstract [

	^self name == #SSWReStoreAbstractQueryTest
]

{ #category : #public }
SSWReStoreAbstractQueryTest >> setUp [

	| john jim david zoe |

	super setUp.

	reStore destroyAllClasses; synchronizeAllClasses.

	reStore beginTransaction.

	john := SimplePerson new 
		surname: 'Smith'; 
		firstName: 'John'; 
		emailAddress: 'john@something'; 
		age: 20;
		storeIn: reStore.

	jim := SimplePerson new 
		surname: 'Brown'; 
		firstName: 'Jim'; 
		emailAddress: 'jim@somewhere'; 
		age: 30;
		storeIn: reStore.

	david := SimplePerson new 
		surname: 'Smythe'; 
		firstName: 'David'; 
		emailAddress: 'david@somewhere'; 
		age: 40;
		storeIn: reStore.

	zoe := SimplePerson new 
		surname: 'Brown'; 
		firstName: 'Zoe';  
		friend: john;
		age: 20;
		yourself;
		storeIn: reStore.

	john friend: david.

	reStore commitTransaction

]

{ #category : #public }
SSWReStoreAbstractQueryTest >> sortedPersonFullNames [

	^#('David Smythe' 'Jim Brown' 'John Smith' 'Zoe Brown')
]
