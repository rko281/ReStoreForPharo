"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreQueryByExampleTest,
	#superclass : #SSWReStoreAbstractQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreQueryByExampleTest >> test1Simple [

	| template instances |

	template := SimplePerson new.
	template time: nil.

	template surname: 'Smith'.
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 1).
	self assert: (instances first firstName = 'John').

	template surname: 'Brown'.
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 2).
	self assert: (instances anySatisfy: [ :each | each firstName = 'Jim']).
	self assert: (instances anySatisfy: [ :each | each firstName = 'Zoe']).

	template firstName: 'Jim'.
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 1).
	self assert: (instances anySatisfy: [ :each | each emailAddress = 'jim@somewhere'])

]

{ #category : #public }
SSWReStoreQueryByExampleTest >> test2Wildcards [

	| template instances |

	template := SimplePerson new.
	template time: nil.

	template surname: 'Sm*' asWildcard.
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 2).
	self assert: (instances anySatisfy: [ :each | each firstName = 'John']).
	self assert: (instances anySatisfy: [ :each | each firstName = 'David']).

	template surname: nil.
	template emailAddress: '*somewhere' asWildcard.
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 2).
	self assert: (instances anySatisfy: [ :each | each firstName = 'Jim']).
	self assert: (instances anySatisfy: [ :each | each firstName = 'David'])
]

{ #category : #public }
SSWReStoreQueryByExampleTest >> test3NilRequired [

	| template instances |

	template := SimplePerson new.
	template time: nil.

	template emailAddress: nil required.	
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 1).
	self assert: (instances first firstName = 'Zoe')
]

{ #category : #public }
SSWReStoreQueryByExampleTest >> test4PersistentByValue [

	| template instances |

	template := SimplePerson new.
	template
		time: nil;
		surname: 'Brown';
		friend: (SimplePerson new time: nil; firstName: 'John').
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 1).
	self assert: (instances first firstName = 'Zoe').
	self assert: (instances first surname = 'Brown').

	template friend surname: 'XYZ'.
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 0)
]

{ #category : #public }
SSWReStoreQueryByExampleTest >> test5PersistentByRef [

	| template instances |

	template := SimplePerson new.
	template
		time: nil;
		surname: 'Brown';
		friend: ((SimplePerson storedInstancesIn: reStore) detect: [ :e | (e firstName = 'John') & (e surname = 'Smith')]).

	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 1).

	self assert: (instances first firstName = 'Zoe').
	self assert: (instances first surname = 'Brown').

	template friend: 
		((SimplePerson storedInstancesIn: reStore) detect: [ :e | (e firstName = 'Jim') & (e surname = 'Brown')]).
	instances := template similarInstancesIn: reStore.
	self assert: (instances size = 0)
]
