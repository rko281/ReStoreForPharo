"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreSpeedTest,
	#superclass : #SSWReStorePersonTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #running }
SSWReStoreSpeedTest >> sampleSet [

	^(1 to: self sampleSize) collect: 
		[ :e | 
		SimplePerson new 
			surname: 'Smith'; 
			firstName: 'John'; 
			emailAddress: 'john@something'; 
			yourself]
]

{ #category : #running }
SSWReStoreSpeedTest >> sampleSize [

	^100
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test1Write [

	| people time |

	people := self sampleSet.

	Transcript 
		cr; 
		show: 'Writing '; print: self sampleSize; show: ' objects... ';
		show: (time := Time millisecondsToRun: [people storeIn: reStore]) displayString;
		show: ' ms'.

	self assert: ((SimplePerson storedInstancesIn: reStore) size = self sampleSize).
	self assert: (time < (self sampleSize * 2)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test2Read [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	people := SimplePerson storedInstancesIn: reStore.

	Transcript 
		cr; 
		show: 'Reading '; print: self sampleSize; show: ' objects... ';
		show:  (time := Time millisecondsToRun: [people := people asOrderedCollection]) displayString;
		show: ' ms'.

	self assert: (people size = self sampleSize).
	self assert: (time < (self sampleSize // 2)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test3Update [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	people := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	people do: 
		[ :person || id |
		id := person _id.
		id odd 
			ifTrue: [person firstName: (person firstName, id displayString)] 
			ifFalse: [person surname: (person surname, id displayString)]].

	Transcript 
		cr; 
		show: 'Updating '; print: self sampleSize; show: ' objects... ';
		show:  (time := Time millisecondsToRun: [people storeAll]) displayString;
		show: ' ms'.

	reStore simulateReconnect.
	(SimplePerson storedInstancesIn: reStore) asOrderedCollection do: 
		[ :person || id |
		id := person _id.
		id odd 
			ifTrue: [self assert: person firstName equals: ('John', id displayString)] 
			ifFalse: [self assert: person surname equals: ('Smith', id displayString)]].

	self assert: (time < (self sampleSize * 2)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test3UpdateViaTransactionNoChange [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect; beginTransaction.

	people := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	people do: [ :person | person firstName].

	Transcript 
		cr; 
		show: 'Updating '; print: self sampleSize; show: ' objects via transaction; no change... ';
		show:  (time := Time millisecondsToRun: [reStore commitTransaction]) displayString;
		show: ' ms'.

	self assert: (time < (self sampleSize * 2)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test3UpdateViaTransactionWithChange [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect; beginTransaction.

	people := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	people do: 
		[ :person || id |
		id := person _id.
		id odd 
			ifTrue: [person firstName: (person firstName, id displayString)] 
			ifFalse: [person surname: (person surname, id displayString)]].

	Transcript 
		cr; 
		show: 'Updating '; print: self sampleSize; show: ' objects via transaction; with change... ';
		show:  (time := Time millisecondsToRun: [reStore commitTransaction]) displayString;
		show: ' ms'.

	reStore simulateReconnect.
	(SimplePerson storedInstancesIn: reStore) asOrderedCollection do: 
		[ :person || id |
		id := person _id.
		id odd 
			ifTrue: [self assert: person firstName equals: ('John', id displayString)] 
			ifFalse: [self assert: person surname equals: ('Smith', id displayString)]].

	self assert: (time < (self sampleSize * 2)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test4RefreshNoChange [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	people := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.

	Transcript 
		cr; 
		show: 'Refreshing (no change) '; print: self sampleSize; show: ' objects... ';
		show:  (time := Time millisecondsToRun: [people refreshAll]) displayString;
		show: ' ms'.

	self assert: (time < (self sampleSize * 2)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test5RefreshWithChange [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	people := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.

	reStore connection evaluateAsTxn:
		[people do: 
			[ :person || id |
			id := person _id.
			id odd ifTrue: [reStore connection exec: ('update simple_person set first_name = ''changed'', version_ = version_ + 1 where id_ = <1p>' expandMacrosWith: id)]].
		true].

	Transcript 
		cr; 
		show: 'Refreshing (changed) '; print: self sampleSize; show: ' objects... ';
		show:  (time := Time millisecondsToRun: [people refreshAll]) displayString;
		show: ' ms'.

	people do: 
		[ :person || id |
		id := person _id.
		id odd
			ifTrue: [self assert: person firstName equals: 'changed'] 
			ifFalse: [self assert: person firstName equals: 'John']].

	self assert: (time < (self sampleSize * 3)) "Fairly arbitrary but keeps an eye on things"
]

{ #category : #'unit tests' }
SSWReStoreSpeedTest >> test9Delete [

	| people time |

	self sampleSet storeAllIn: reStore.

	reStore simulateReconnect.

	people := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	
	Transcript 
		cr; 
		show: 'Deleting '; print: self sampleSize; show: ' objects... ';
		show:  (time := Time millisecondsToRun: [people unstoreAll]) displayString;
		show: ' ms'.

	self assert: (SimplePerson storedInstancesIn: reStore) isEmpty.
	self assert: (time < (self sampleSize * 2)) "Fairly arbitrary but keeps an eye on things"
]
