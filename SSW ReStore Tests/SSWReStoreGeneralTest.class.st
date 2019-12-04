"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreGeneralTest,
	#superclass : #SSWReStoreTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> _test21GeneralDictionaryRefresh [

	"Currently not working - issues around rebuilding a Dictionary (needing rehash = needs access to key objects) during refresh"

	| t key value keyOrig valueOrig |

	"Check refresh of keys - general dict"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	key := t keyedGeneralDictionary keys asArray first.
	value := t keyedGeneralDictionary at: key.

	keyOrig := key name.
	valueOrig := value name.

	key name: keyOrig, '_changed'.
	value name: valueOrig, '_changed'.

	reStore refresh: t keyedGeneralDictionary withRelatedComponents.

	self assert: (key name = keyOrig).
	self assert: (value name = valueOrig)
]

{ #category : #running }
SSWReStoreGeneralTest >> setUp [

	super setUp.

	self createStandardTestInstance.
	reStore simulateReconnect
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test01Events [

	"Check persistency of events"

	| t counter |

	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	counter := OrderedCollection new.

	reStore beginTransaction.
	t single1 when: #something send: #yourself to: t.
	t single1 name: 'blah'.
	t list when: #listChanged send: #add: to: counter with: 1.
	t ownedList when: #listChanged send: #add: to: counter with: 2.
	t list removeLast.
	t ownedList removeLast.
	reStore rollbackTransaction.

	self assert: (t single1 getEvents includesKey: #something).
	self assert: (t list getEvents includesKey: #listChanged).
	self assert: (t ownedList getEvents includesKey: #listChanged).
	self assert: (counter asSortedCollection asArray = #(1 2))

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test02Rollback [

	| t kd |

	"Test rollback"
	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	reStore  beginTransaction.
	t single1 name: 'single A'.
	t single2 name: 'single B'.
	t single3: (Test new name: 'single C').
	t ownedSet remove: (t ownedSet detect: [ :e | true]).
	t setOfDates add: (Date today subtractDays: 900).
	t arrayOfNames at: 2 put: 'Weed'.
	t orderedBools atAllPut: true.
	t sortedNumbers remove: 1; add: 0; add: 99.
	t descNumbers remove: 1; add: 0; add: 99.
	t listOfTimes add: Time now.
	t dictOfSizes removeKey: 'Pogle'; at: 'Pippin' put: 'Pippin' size.
	t ownedOrdered addLast: t ownedOrdered first; removeFirst.
	t ownedSorted remove: (t ownedSet detect: [ :e | true]).
	t ownedList removeFirst.
	t set remove: (t set detect: [ :e | e name = 'set1']); add: (Test new name: 'set3').
	t array at: 3 put: (t array at: 1); at: 4 put: (Test new name: 'array4'); at: 1 put: nil.
	t ordered addLast: t ordered first; removeFirst; addLast: (Test new name: 'ordered4').
	t sorted add: (Test new name: 'sorted0'); add: (Test new name: 'sorted3').
	t list addLast: t list first; removeFirst; addLast: (Test new name: 'list4').
	t aspectDictionary removeKey: 'aspdic1'; at: 'aspdic4' put: (Test new name: 'aspdic4'; yourself).
	kd := t keyedBaseDictionary.
	kd 
		at: 'b' put: (kd at: 'a'); 
		at: 'a' put: (Test new name: 'keydic1a'; yourself); 
		removeKey: 'c'; 
		at: 'd' put: (Test new name: 'keydic4'; yourself).
	kd := t keyedGeneralDictionary.
	kd 
		at: (kd keys detect: [ :e | e name = 'key2']) put: (kd values detect: [ :e | e name = 'value1']);
		at: (kd keys detect: [ :e | e name = 'key1']) put: (Test new name: 'value1a'; yourself);
		removeKey: (kd keys detect: [ :e | e name = 'key3']);
		at: (Test new name: 'key4'; yourself) put: (Test new name: 'value4'; yourself).
	kd := nil.
	reStore rollbackTransaction.

	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	self assert: (t single1 name = 'single1').
	self assert: (t single2 name = 'single2').
	self assert: (t single2 == t single3).
	self assert: (t ownedSet isEmpty not).
	self assert: (t setOfDates size = 2).
	self assert: (t setOfDates includes: Date today).
	self assert: (t setOfDates includes: (Date today subtractDays: 92)).
	self assert: (t arrayOfNames = #('Bill' 'Ben')).
	self assert: (t orderedBools includes: true).
	self assert: (t orderedBools includes: false).
"	self assert: (t orderedBools includes: nil)."
	self assert: (t orderedBools size = 3).
	self assert: (t sortedNumbers asArray = #(1 2 3)).
	self assert: (t descNumbers asArray = #(3 2 1)).
	self assert: (t listOfTimes size = 1).
	self assert: ((t dictOfSizes at: 'Pogle' ifAbsent: [0]) = 5).
	self assert: ((t dictOfSizes at: 'Tog' ifAbsent: [0]) = 3).
	self assert: ((t ownedArray collect: [ :e | e ifNil: ['nil'] ifNotNil: [e name]]) asSortedCollection asArray = (Array with: 'nil' with: 'nil' with: 'owned1' with: 'owned2')). "ordering of owned collections is usually in order of creation, but is technically arbitrary"
	self assert: (t array first name = 'array1').
	self assert: ((t array at: 2) name = 'array2').
	self assert: (t set size = 2).
	self assert: (t set anySatisfy: [ :e | e name = 'set1']).

	self assert: (t set anySatisfy: [ :e | e name = 'set2']).
	self assert: (t ordered size = 2).
	self assert: (t ordered anySatisfy: [ :e | e name = 'ordered1']).
	self assert: (t ordered anySatisfy: [ :e | e name = 'ordered2']).
	self assert: (t sorted size = 2).
	self assert: (t sorted anySatisfy: [ :e | e name = 'sorted1']).
	self assert: (t sorted anySatisfy: [ :e | e name = 'sorted2']).
	self assert: (t list size = 2).
	self assert: (t list anySatisfy: [ :e | e name = 'list1']).
	self assert: (t list anySatisfy: [ :e | e name = 'list2']).

	self assert: (t aspectDictionary size = 3).
	self assert: ((t aspectDictionary at: 'aspdic1') name = 'aspdic1').
	self assert: ((t aspectDictionary at: 'aspdic2') name = 'aspdic2').
	self assert: ((t aspectDictionary at: 'aspdic3') name = 'aspdic3').

	self assert: (t keyedBaseDictionary size = 3).
	self assert: ((t keyedBaseDictionary at: 'a') name = 'keydic1').
	self assert: ((t keyedBaseDictionary at: 'b') name = 'keydic2').
	self assert: ((t keyedBaseDictionary at: 'c') name = 'keydic3').

	self assert: (t keyedGeneralDictionary size = 3).
	t keyedGeneralDictionary keysAndValuesDo:
		[ :key :value |
		self assert: (key name beginsWith: 'key').
		self assert: (value name beginsWith: 'value').
		self assert: (key name last = value name last)]
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test02RollbackManual [

	| t n |

	"Test rollbackAll: (manual rollback)"
	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	t single1 name: 'single AA'.
	n := t single2.
	t single2: nil.
	t single3: (Test new name: 'single3').
	t ordered addLast: (Test new name: 'ordered 99').
	reStore rollbackAll: (Array with: t with: t ordered with: t single1 with: n unstored with: t single3).

	self assert: (t single1 name = 'single1').
	self assert: (t single2 notNil and: [t single2 name = 'single2']).
	self assert: ((reStore instancesOf: Test) anySatisfy: [ :e | e name = 'single2']).
	self assert: (t single3 == t single2).
	self deny: ((reStore instancesOf: Test) anySatisfy: [ :e | e name = 'single3']).
	self assert: (t ordered size = 2).
	self assert: (t ordered last name = 'ordered2')
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test03Commit [

	| t kd |

	"Test commit"
	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	"Check commit"
	reStore beginTransaction.
	t single1 name: 'single A'.
	t single2 name: 'single B'.
	t single3: (OwnedTest new name: 'single D').
	"t ownedSet remove: (t ownedSet detect: [ :e | true]); add: (OwnedTest new name: 'owned0')."
	"t ownedArray at: 3 put: (t ownedArray at: 1); at: 1 put: nil; at: 4 put: (OwnedTest new name: 'owed4')."
	t ownedOrdered removeFirst; addLast: t single3.
	"t ownedSorted remove: (t ownedSet detect: [ :e | true]); add: (t ownedArray at: 4)."
	t setOfDates add: (Date today subtractDays: 900).
	t arrayOfNames at: 2 put: 'Weed'.
	t orderedBools atAllPut: true.
	t sortedNumbers remove: 1; add: 0; add: 99.
	t descNumbers remove: 1; add: 0; add: 99.
	t listOfTimes add: Time now.
	t dictOfSizes removeKey: 'Pogle'; at: 'Pippin' put: 'Pippin' size.
	t set remove: (t set detect: [ :e | e name = 'set1']); add: (Test new name: 'set3').
	t array at: 3 put: (t array at: 1); at: 4 put: (Test new name: 'array4'); at: 1 put: nil.
	t ordered addLast: t ordered first; removeFirst; addLast: (Test new name: 'ordered4').
	t sorted add: (Test new name: 'sorted0'); add: (Test new name: 'sorted3').
	t list addLast: t list first; removeFirst; addLast: (Test new name: 'list4').
	t aspectDictionary removeKey: 'aspdic1'; at: 'aspdic4' put: (Test new name: 'aspdic4'; yourself).
	kd := t keyedBaseDictionary.
	kd 
		at: 'b' put: (kd at: 'a'); 
		at: 'a' put: (Test new name: 'keydic1a'; yourself); 
		removeKey: 'c'; 
		at: 'd' put: (Test new name: 'keydic4'; yourself).
	kd := t keyedGeneralDictionary.
	kd 
		at: (kd keys detect: [ :e | e name = 'key2']) put: (kd values detect: [ :e | e name = 'value1']);
		at: (kd keys detect: [ :e | e name = 'key1']) put: (Test new name: 'value1a'; yourself);
		removeKey: (kd keys detect: [ :e | e name = 'key3']);
		at: (Test new name: 'key4'; yourself) put: (Test new name: 'value4'; yourself).
	kd := nil.

	reStore commitTransaction.

	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	self assert: (t single1 name = 'single A').
	self assert: (t single2 name = 'single B').
	self assert: (t single3 name = 'single D').
	self assert: (t ownedOrdered first name beginsWith: 'owned').
	self assert: (t ownedOrdered last == t single3).
	self assert: (t setOfDates size = 3).
	self assert: (t setOfDates includes: Date today).
	self assert: (t setOfDates includes: (Date today subtractDays: 92)).
	self assert: (t setOfDates includes: (Date today subtractDays: 900)).
	self assert: (t arrayOfNames = #('Bill' 'Weed')).
	self assert: (t orderedBools includes: true).
	self deny: (t orderedBools includes: false).
	self assert: (t orderedBools size = 3).
	self assert: (t sortedNumbers asArray = #(0 2 3 99)).
	self assert: (t descNumbers asArray = #(99 3 2 0)).
	self assert: (t listOfTimes size = 2).
	self assert: (t dictOfSizes size = 2).
	self assert: ((t dictOfSizes at: 'Pippin' ifAbsent: [0]) = 6).
	self assert: ((t dictOfSizes at: 'Tog' ifAbsent: [0]) = 3).
	self assert: (t set size = 2).
	self assert: (t set anySatisfy: [ :e | e name = 'set2']).
	self assert: (t set anySatisfy: [ :e | e name = 'set3']).
	self assert: (t array first isNil).
	self assert: ((t array at: 2) name = 'array2').
	self assert: ((t array at: 3) name = 'array1').
	self assert: ((t array at: 4) name = 'array4').
	self assert: (t ordered size = 3).
	self assert: (t ordered first name = 'ordered2').
	self assert: ((t ordered at: 2) name = 'ordered1').
	self assert: (t ordered last name = 'ordered4').
	self assert: (t sorted size = 4).
	self assert: (t sorted first name = 'sorted0').
	self assert: ((t sorted at: 2) name = 'sorted1').
	self assert: ((t sorted at: 3) name = 'sorted2').
	self assert: (t sorted last name = 'sorted3').
	self assert: (t list size = 3).
	self assert: (t list first name = 'list2').
	self assert: ((t list at: 2) name = 'list1').
	self assert: (t list last name = 'list4').

	self assert: (t aspectDictionary size = 3).
	self assert: ((t aspectDictionary at: 'aspdic4') name = 'aspdic4').
	self assert: ((t aspectDictionary at: 'aspdic2') name = 'aspdic2').
	self assert: ((t aspectDictionary at: 'aspdic3') name = 'aspdic3').

	self assert: (t keyedBaseDictionary size = 3).
	self assert: ((t keyedBaseDictionary at: 'a') name = 'keydic1a').
	self assert: ((t keyedBaseDictionary at: 'b') name = 'keydic1').
	self assert: ((t keyedBaseDictionary at: 'd') name = 'keydic4').

	self assert: (t keyedGeneralDictionary size = 3).
	t keyedGeneralDictionary keysAndValuesDo:
		[ :key :value |
		self assert: (key name beginsWith: 'key').
		self assert: (value name beginsWith: 'value').
		key name = 'key1' ifTrue: [self assert: (value name = 'value1a')].
		key name = 'key2' ifTrue: [self assert: (value name = 'value1')].
		key name = 'key4' ifTrue: [self assert: (value name = 'value4')]].
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test03CommitManual [

	| t n prevSize |

	"Test commitAll: (manual commit)"
	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	prevSize := t ordered size.

	n := t single1.
	t single1: nil.
	t single2 name: 'single BB'.
	t single3: (Test new name: 'single CC').
	t ordered addLast: (Test new name: 'ordered 99').
	reStore commitAll: (Array with: t with: t ordered with: n unstored with: t single2 with: t single3).

	reStore refreshAllObjects.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	self assert: (t single1 = nil).
	self assert: (t single2 name = 'single BB').
	self deny: ((reStore instancesOf: Test) anySatisfy: [ :each | each name = 'single A']).
	self assert: (t single3 name = 'single CC').
	self assert: (t ordered size = (prevSize + 1)).
	self assert: (t ordered last name = 'ordered 99').

	t ordered removeLast.
	reStore commitAll: (Array with: t ordered).
	reStore refreshAllObjects.
	self assert: (t ordered size = prevSize)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test03LinkedQuery [

	| owner |

	owner := (reStore instancesOf: OwnerTest) first.

	self deny: (((reStore instancesOf: OwnedTest) select: [ :each | each owner = owner]) isEmpty)

	
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test04 [

	| t prevName r |

	"Check Delete on Replace - owned"
	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	prevName := t ownedOrdered first name.

	reStore beginTransaction.
	t ownedOrdered at: 1 put: (OwnedTest new name: 'owned rep1'; yourself).
	reStore commitTransaction.

	reStore clearProxyCache.
	r := (reStore instancesOf: Test satisfying: [ :each | each name = 'owned rep1']) asOrderedCollection.
	self assert: (r size = 1).
	self assert: (r first name = 'owned rep1').

	r := (reStore instancesOf: Test satisfying: [ :each | each name = prevName]) asOrderedCollection.
	self assert: r isEmpty
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test05 [

	| t r d c id |

	"Check Delete on Remove - owned"
	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	d := t ownedOrdered detect: [ :each | each name = 'owned1'].
	c := (reStore tableForClass: d class) registerClass.
	id := d _id.
	self assert: ((reStore proxyCache at: c) includesKey: id).

	t ownedOrdered remove: d.
	reStore commitTransaction.
	self deny: ((reStore proxyCache at: c) includesKey: id).

	reStore clearProxyCache.
	r := (reStore instancesOf: Test satisfying: [ :each | each name = 'owned1']) asOrderedCollection.
	self assert: r isEmpty
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test06 [

	| t r |

	"Check Delete on Replace - unrefd ordered
	Starting scenario is ordered1-ordered2"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t ordered at: 1 put: (OwnedTest new name: 'ordered rep1'; yourself).
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t ordered first name = 'ordered rep1').
	r := (reStore instancesOf: Test satisfying: [ :each | 'ordered*' match: each name]) asOrderedCollection.
	self assert: (r size = 2).
	self deny: (r anySatisfy: [ :each | each name = 'ordered1'])
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test07 [

	| t |

	"Check non-delete on Replace - refd ordered
	Starting scenario is ordered ordered1-ordered2"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t ordered addLast: t ordered first.
	t ordered at: 1 put: (OwnedTest new name: 'ordered rep1a'; yourself).
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t ordered first name = 'ordered rep1a').
	self assert: (t ordered second name = 'ordered2').
	self assert: (t ordered last name = 'ordered1')
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test08 [

	| t |

	"Check delete on Replace - unrefd changed ordered
	Starting scenario is ordered rep1a-ordered1-ordered4-ordered rep1"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t ordered first name: 'xxxx'.
	t ordered at: 1 put: (OwnedTest new name: 'ordered rep1b'; yourself).
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t ordered first name = 'ordered rep1b').
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'ordered rep1a']) isEmpty).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'xxxx']) isEmpty).

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test09 [

	| t |

	"Check delete on Remove.
	Starting scenario is ordered1-ordered2"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t ordered removeFirst.
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t ordered size = 1).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'ordered1']) isEmpty)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test10 [

	| t |

	"Check no delete for duplicates.
	Starting scenario is ordered1-ordered2"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t ordered addFirst: t ordered removeLast.
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t ordered size = 2).
	self assert: (t ordered first name = 'ordered2').
	self deny: (t ordered last == t ordered first)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test11 [

	| t |

	"Check Delete on Replace - unrefd list
	Starting scenario is list1-list2"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t list at: 1 put: (OwnedTest new name: 'list rep1'; yourself).
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t list first name = 'list rep1').
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'list1']) isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test12 [

	| t |

	"Check delete on Remove - list.
	Starting scenario is list1-list2"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t list removeLast.
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t list size = 1).
	self assert: (t list first name = 'list1').
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'list2']) isEmpty)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test13 [

	| t |

	"Check delete on Remove - aspect dict"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t aspectDictionary removeKey: 'aspdic2'.
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t aspectDictionary size = 2).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'aspdic2']) isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test14 [

	| t |

	"Check delete on Remove - base dict
	Starting scenario is a>1, b>2, c>3"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t keyedBaseDictionary removeKey: 'b'.
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t keyedBaseDictionary size = 2).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'keydic2']) isEmpty)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test15 [

	| t |

	"Check delete on Replace - base dict
	Starting scenario is a>1, b>2, c>3"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t keyedBaseDictionary at: 'a' put: (Test new name: 'keydic1b').
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t aspectDictionary size = 3).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'keydic1a']) isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test16 [

	| t |

	"Check delete on Remove - general dict
	Starting scenario is 1>1, 2>2, 3>3"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t keyedGeneralDictionary removeKey: (t keyedGeneralDictionary keys detect: [ :e | e name = 'key1']).
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t keyedGeneralDictionary size = 2).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'key1']) isEmpty).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'value1']) isEmpty)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test17 [

	| t |

	"Check delete on Replace - base dict
	Starting scenario is 1>1, 2>2, 3>3"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	t keyedGeneralDictionary 
		at: (t keyedGeneralDictionary keys detect: [ :e | e name = 'key2'])
		put: (Test new name: 'value2a').
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t keyedGeneralDictionary size = 3).
	self assert: (t keyedGeneralDictionary at: (t keyedGeneralDictionary keys detect: [ :e | e name = 'key2'])) name = 'value2a'.
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'value2']) isEmpty)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test18 [

	| t key3 |

	"Check no delete on Remove if ref'd - general dict
	Starting scenario is 1>1, 2>2, 3>3"

	reStore clearProxyCache.

	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	key3 := t keyedGeneralDictionary keys detect: [ :e | e name = 'key3'].

	reStore beginTransaction.
	t keyedGeneralDictionary 
		at: (Test new name: 'key3a') 
		put: (t keyedGeneralDictionary at: key3).
	t keyedGeneralDictionary removeKey: key3.

	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: (t keyedGeneralDictionary size = 3).
	self assert: ((reStore instancesOf: Test satisfying: [ :each | each name = 'key3']) isEmpty).
	self deny: ((reStore instancesOf: Test satisfying: [ :each | each name = 'value3']) isEmpty)

]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test20GeneralDictionaryRollback [

	| t key value keyOrig valueOrig |

	"Check refresh of keys - general dict"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	key := t keyedGeneralDictionary keys asArray first.
	value := t keyedGeneralDictionary at: key.

	keyOrig := key name.
	valueOrig := value name.

	key name: keyOrig, '_changed'.
	value name: valueOrig, '_changed'.

	reStore rollback: t keyedGeneralDictionary withRelatedComponents.

	self assert: (key name = keyOrig).
	self assert: (value name = valueOrig)
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test30GeneralCollectionRollback [

	| t value valueOrig |

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	value := t ordered first .
	valueOrig := value name.
	value name: valueOrig, '_changed'.

	reStore rollback: t ordered withRelatedComponents.

	self assert: (value name = valueOrig)
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test31GeneralCollectionRefresh [

	| t value valueOrig |

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.

	value := t ordered first .
	valueOrig := value name.
	value name: valueOrig, '_changed'.

	reStore refresh: t ordered withRelatedComponents.

	self assert: (value name = valueOrig)
]

{ #category : #'unit tests' }
SSWReStoreGeneralTest >> test99 [

	| t |

	"Check cascaded delete"

	reStore clearProxyCache.
	t := (reStore instancesOf: OwnerTest) asOrderedCollection last.
	reStore beginTransaction.

	self assert: ((reStore instancesOf: Test) size = (2 "single1, single2" + t set size + t array size + t ordered size + t sorted size + t list size + t aspectDictionary size + t keyedBaseDictionary size + t keyedGeneralDictionary keys size + t keyedGeneralDictionary values size)).

	t unstore.
	reStore commitTransaction.

	reStore clearProxyCache.
	self assert: ((reStore instancesOf: Test) size = 1). "single1 is non-dependent so isn't deleted"
]
