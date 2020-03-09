"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreInlinedTest,
	#superclass : #SSWReStorePersonTest,
	#instVars : [
		'persons'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #running }
SSWReStoreInlinedTest >> addClassesTo: aReStore [

	reStore addClass: InlinedTestPerson; addClass: SimpleAddress
]

{ #category : #running }
SSWReStoreInlinedTest >> setUp [

	super setUp.

	(Array 
		with: 
			(InlinedTestPerson new 
				firstName: 'Adam';
				surname: 'Barnes';
				address1: 
					(InlinedAddress new line1: '1 a road'; postcode: 
						(InlinedPostcode new code1: 'a1'; code2: '0aa'));
				address2: 
					(InlinedAddress new line1: '2 another road'; postcode: 
						(InlinedPostcode new code1: 'n22'; code2: '0aa'));
				address3: 
					(SimpleAddress new line1: '3 a street'; postcode: 'a3 0aa');
				line1: 'aline1';
				code1: 'acode1';
				bankBalance: (NumberWithCurrency new number: 1.23; currency: 'USD'; yourself);
				yourself)
		with: 
			(InlinedTestPerson new 
				firstName: 'Dave';
				surname: 'Jones';
				address1: 
					(InlinedAddress new line1: '1 some st'; postcode: 
						(InlinedPostcode new code1: 'n1'; code2: '1aa'));
				address2: 
					(InlinedAddress new line1: '2 some st'; postcode: 
						(InlinedPostcode new code1: 'n2'; code2: '2aa'));
				address3: 
					(SimpleAddress new line1: '3 some st'; postcode: 'n3 3aa');
				line1: 'dline1';
				code1: 'dcode1';
				bankBalance: (NumberWithCurrency new number: 123.45; currency: 'GBP'; yourself);
				yourself)
		with: 
			(InlinedTestPerson new 
				firstName: 'John';
				surname: 'Smith';
				address1: 
					(InlinedAddress new line1: '1 some road'; postcode: 
						(InlinedPostcode new code1: 'e1'; code2: '1aa'));
				address2: 
					(InlinedAddress new line1: '2 some road'; postcode: 
						(InlinedPostcode new code1: 'e2'; code2: '2aa'));
				address3: 
					(SimpleAddress new line1: '3 some road'; postcode: 'e3 3aa');
				line1: 'jline1';
				code1: 'jcode1';
				bankBalance: (NumberWithCurrency new number: 987.65; currency: 'EUR'; yourself);
				yourself)) storeAllIn: reStore.


	reStore simulateReconnect.

	persons := (reStore instancesOf: InlinedTestPerson) sortBlock: [ :p1 :p2 | p1 firstName <= p2 firstName]
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test01Verify [

	persons := persons asSortedCollection.

	self assert: (persons size = 3).

	"Verify inlined fields are actually inlined"
	self assert: (reStore tableForClass: InlinedTestPerson) dataFields size equals: 
		#('firstName' 'surname'
		'address1-line1' 'address1-postcode-code1' 'address1-postcode-code2'
		'address2-line1' 'address2-postcode-code1' 'address2-postcode-code2'
		'address3' 'line1' 'code1'
		'bankBalance-amount' 'bankBalance-currency') size. 

	self assert: ((reStore tableForClass: InlinedTestPerson) dataFields select: [ :each | each accessor isInlined]) size equals: 
		#('address1-line1' 'address1-postcode-code1' 'address1-postcode-code2'
		'address2-line1' 'address2-postcode-code1' 'address2-postcode-code2'
		'bankBalance-amount' 'bankBalance-currency') size. 
	
	self assert: (persons first firstName = 'Adam').
	self assert: (persons first surname = 'Barnes').
	self assert: (persons first line1 = 'aline1').
	self assert: (persons first code1 = 'acode1').

	self assert: (persons second firstName = 'Dave').
	self assert: (persons second surname = 'Jones').
	self assert: (persons second line1 = 'dline1').
	self assert: (persons second code1 = 'dcode1').
	
	self assert: (persons second address1 notNil).
	self assert: (persons second address1 line1 = '1 some st').
	self assert: (persons second address1 postcode code1 = 'n1').
	self assert: (persons second address1 postcode code2 = '1aa').

	self assert: (persons second address2 notNil).
	self assert: (persons second address2 line1 = '2 some st').
	self assert: (persons second address2 postcode code1 = 'n2').
	self assert: (persons second address2 postcode code2 = '2aa').

	self assert: (persons second address3 notNil).
	self assert: (persons second address3 line1 = '3 some st').
	self assert: (persons second address3 postcode = 'n3 3aa').

	self assert: (persons last firstName = 'John').
	self assert: (persons last surname = 'Smith').
	self assert: (persons last line1 = 'jline1').
	self assert: (persons last code1 = 'jcode1').

	self assert: (persons last address1 notNil).
	self assert: (persons last address1 line1 = '1 some road').
	self assert: (persons last address1 postcode code1 = 'e1').
	self assert: (persons second address1 postcode code2 = '1aa').

	self assert: persons second bankBalance displayString equals: '123.45 GBP'.

	self assert: (persons last address2 notNil).
	self assert: (persons last address2 line1 = '2 some road').
	self assert: (persons last address2 postcode code1 = 'e2').
	self assert: (persons second address2 postcode code2 = '2aa').

	self assert: (persons last address3 notNil).
	self assert: (persons last address3 line1 = '3 some road').
	self assert: (persons last address3 postcode = 'e3 3aa')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test02QuerySimple [

	| dave john |

	"Regular non-inlined"
	dave := persons detect: [ :each | each firstName = 'Dave'] ifNone: [nil].
	self assert: (dave notNil).
	self assert: (dave firstName = 'Dave').

	dave := persons detect: [ :each | each firstName = 'XXX'] ifNone: [nil].
	self assert: (dave isNil).

	john := persons detect: [ :each | each firstName = 'John'] ifNone: [nil].
	self assert: (john notNil).
	self assert: (john firstName = 'John').

	john := persons detect: [ :each | each firstName = 'YYY'] ifNone: [nil].
	self assert: (john isNil)
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test03QueryFirstLevelInlined [

	| dave john |

	"First level inlined"
	dave := persons detect: [ :each | each address1 line1 = '1 some st'] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	dave := persons detect: [ :each | each bankBalance currency = 'GBP'] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	dave := persons detect: [ :each | each address1 line1 = '99 some st'] ifNone: [nil].
	self assert: (dave isNil).

	dave := persons detect: [ :each | each bankBalance currency = 'JPY'] ifNone: [nil].
	self assert: (dave isNil).

	john := persons detect: [ :each | each address2 line1 = '2 some road'] ifNone: [nil].
	self assert: (john notNil).
	self assert: john firstName equals: 'John'.

	john := persons detect: [ :each | each bankBalance currency = 'EUR'] ifNone: [nil].
	self assert: (john notNil).
	self assert: john firstName equals: 'John'
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test03QueryFirstLevelInlinedEquality [

	"Test correct use of inlined classes own definitions of equality"

	| postcode address dave john |

	dave := persons detect: [ :each | each bankBalance = (NumberWithCurrency new number: 123.45; currency: 'GBP'; yourself)] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	postcode := InlinedPostcode new code1: 'n1'; code2: '1aa'.
	dave := persons detect: [ :each | each address1 postcode = postcode] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	address := InlinedAddress new line1: '1 some st'; postcode: postcode.
	dave := persons detect: [ :each | each address1 = address] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	postcode code1: '9z'.
	dave := persons detect: [ :each | each address1 = address] ifNone: [nil].
	self assert: (dave isNil).
	
	postcode := InlinedPostcode new code1: 'e2'; code2: '2aa'.
"	john := persons detect: [ :each | (each address2 postcode = postcode) & ('j*' match: each firstName)] ifNone: [nil].
	self assert: (john notNil).
	self assert: john firstName equals: 'John'.
"
	address := InlinedAddress new line1: '2 some road'; postcode: postcode.
	john := persons detect: [ :each | ('S*' match: each surname) & (each address2 = address)] ifNone: [nil].
	self assert: (john notNil).
	self assert: john firstName equals: 'John'.

	address := InlinedAddress new line1: '9999 some road'; postcode: postcode.
	john := persons detect: [ :each | each address2 = address] ifNone: [nil].
	self assert: (john isNil).

	postcode := InlinedPostcode new code1: 'z2'; code2: '2aa'.
	john := persons detect: [ :each | each address2 postcode = postcode] ifNone: [nil].
	self assert: (john isNil).

	address := InlinedAddress new line1: '222222 some road'; postcode: postcode.
	john := persons detect: [ :each | each address2 = address] ifNone: [nil].
	self assert: (john isNil).
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test04QuerySecondLevelInlined [

	| dave john daveAndJohn |

	"Second-level inlined"
	dave := persons detect: [ :each | each address1 postcode code1 = 'n1'] ifNone: [nil].
	self assert: (dave notNil).
	self assert: (dave firstName = 'Dave').

	daveAndJohn := persons select: [ :each | each address1 postcode code2 = '1aa'].
	self assert: (daveAndJohn size = 2).
	self assert: (daveAndJohn anySatisfy: [ :each | each firstName = 'Dave']).
	self assert: (daveAndJohn anySatisfy: [ :each | each firstName = 'John']).

	dave := persons detect: [ :each | each address1 postcode code1 = '1aa'] ifNone: [nil].
	self assert: (dave isNil).

	dave := persons detect: [ :each | each address1 postcode code2 = 'n1'] ifNone: [nil].
	self assert: (dave isNil).

	john := persons detect: [ :each | each address2 postcode code1 = 'e2'] ifNone: [nil].
	self assert: (john notNil).
	self assert: (john firstName = 'John').

	daveAndJohn := persons select: [ :each | each address2 postcode code2 = '2aa'].
	self assert: (daveAndJohn size = 2).
	self assert: (daveAndJohn anySatisfy: [ :each | each firstName = 'Dave']).
	self assert: (daveAndJohn anySatisfy: [ :each | each firstName = 'John']).

	john := persons detect: [ :each | each address2 postcode code1 = '2aa'] ifNone: [nil].
	self assert: (john isNil).

	john := persons detect: [ :each | each address2 postcode code2 = 'e2'] ifNone: [nil].
	self assert: (john isNil)
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test05QueryDisambiguation [

	| dave john |

	dave := persons detect: [ :each | each line1 = 'dline1'] ifNone: [nil].
	self assert: (dave notNil).
	self assert: (dave firstName = 'Dave').

	dave := persons detect: [ :each | each line1 = dave address1 line1] ifNone: [nil].
	self assert: (dave isNil).

	dave := persons detect: [ :each | each code1 = 'dcode1'] ifNone: [nil].
	self assert: (dave notNil).
	self assert: (dave firstName = 'Dave').

	dave := persons detect: [ :each | each code1 = dave address1 postcode code1] ifNone: [nil].
	self assert: (dave isNil).


	john := persons detect: [ :each | each line1 = 'jline1'] ifNone: [nil].
	self assert: (john notNil).
	self assert: (john firstName = 'John').

	john := persons detect: [ :each | each line1 = john address2 line1] ifNone: [nil].
	self assert: (john isNil).

	john := persons detect: [ :each | each code1 = 'jcode1'] ifNone: [nil].
	self assert: (john notNil).
	self assert: (john firstName = 'John').

	john := persons detect: [ :each | each code1 = john address2 postcode code1] ifNone: [nil].
	self assert: (john isNil).
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test06QueryByExampleSimple [

	| exDave similar |

	exDave := InlinedTestPerson new firstName: 'Dave'.
	similar  := exDave similarInstancesIn: reStore.
	self assert: (similar  size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new firstName: 'Davey'.
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test07QueryByExampleFirstLevelInlined [

	| exDave similar |

	"First level inlined"
	exDave := InlinedTestPerson new address1: (InlinedAddress new line1: '1 some st').
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new address2: (InlinedAddress new line1: '2 some st').
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new address1: (InlinedAddress new line1: '2 some st').
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

	exDave := InlinedTestPerson new address2: (InlinedAddress new line1: '1 some st').
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty)
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test08QueryByExampleSecondLevelInlined [

	| exDave similar |

	"Second level inlined"
	exDave := InlinedTestPerson new address1: (InlinedAddress new postcode: (InlinedPostcode new code1: 'n1')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new address2: (InlinedAddress new postcode: (InlinedPostcode new code1: 'n2')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new address2: (InlinedAddress new postcode: (InlinedPostcode new code1: 'n3')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

	exDave := InlinedTestPerson new address2: (InlinedAddress new postcode: (InlinedPostcode new code1: 'n4')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

	exDave := InlinedTestPerson new address1: (InlinedAddress new postcode: (InlinedPostcode new code2: '1aa')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 2).
	self assert: ((similar collect: [ :each | each firstName]) asSortedCollection asArray = #('Dave' 'John')).

	exDave := InlinedTestPerson new address2: (InlinedAddress new postcode: (InlinedPostcode new code2: '2aa')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 2).
	self assert: ((similar collect: [ :each | each firstName]) asSortedCollection asArray = #('Dave' 'John')).

	exDave := InlinedTestPerson new address2: (InlinedAddress new postcode: (InlinedPostcode new code2: '3aa')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

	exDave := InlinedTestPerson new address2: (InlinedAddress new postcode: (InlinedPostcode new code2: '4aa')).
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test09QueryByExampleDisambiguation [

	| exDave exJohn similar |

	exDave := InlinedTestPerson new line1: 'dline1'.
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new line1: similar first address1 line1.
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

	exJohn := InlinedTestPerson new line1: 'jline1'.
	similar := exJohn similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'John').

	exJohn := InlinedTestPerson new line1: similar first address2 line1.
	similar := exJohn similarInstancesIn: reStore.
	self assert: (similar isEmpty).


	exDave := InlinedTestPerson new code1: 'dcode1'.
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'Dave').

	exDave := InlinedTestPerson new code1: similar first address1 postcode code1.
	similar := exDave similarInstancesIn: reStore.
	self assert: (similar isEmpty).

	exJohn := InlinedTestPerson new code1: 'jcode1'.
	similar := exJohn similarInstancesIn: reStore.
	self assert: (similar size = 1).
	self assert: (similar first firstName = 'John').

	exJohn := InlinedTestPerson new line1: similar first address2 postcode code1.
	similar := exJohn similarInstancesIn: reStore.
	self assert: (similar isEmpty).
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test09QueryInlinedEquality [

	"Test correct use of inlined classes own definitions of equality"

	| postcode address dave john |

	dave := persons detect: [ :each | each bankBalance = (NumberWithCurrency new number: 123.45; currency: 'GBP'; yourself)] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	dave := persons detect: [ :each | each bankBalance = (NumberWithCurrency new number: 923.45; currency: 'GBP'; yourself)] ifNone: [nil].
	self assert: (dave isNil).

	dave := persons detect: [ :each | each bankBalance = (NumberWithCurrency new number: 123.45; currency: 'USD'; yourself)] ifNone: [nil].
	self assert: (dave isNil).

	postcode := InlinedPostcode new code1: 'n1'; code2: '1aa'.
	dave := persons detect: [ :each | each address1 postcode = postcode] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	address := InlinedAddress new line1: '1 some st'; postcode: postcode.
	dave := persons detect: [ :each | each address1 = address] ifNone: [nil].
	self assert: (dave notNil).
	self assert: dave firstName equals: 'Dave'.

	postcode code1: '9z'.
	dave := persons detect: [ :each | each address1 = address] ifNone: [nil].
	self assert: (dave isNil).
	
	postcode := InlinedPostcode new code1: 'e2'; code2: '2aa'.
	john := persons detect: [ :each | (each address2 postcode = postcode) & ('J*' match: each firstName)] ifNone: [nil].
	self assert: (john notNil).
	self assert: john firstName equals: 'John'.

	address := InlinedAddress new line1: '2 some road'; postcode: postcode.
	john := persons detect: [ :each | ('S*' match: each surname) & (each address2 = address)] ifNone: [nil].
	self assert: (john notNil).
	self assert: john firstName equals: 'John'.

	address := InlinedAddress new line1: '9999 some road'; postcode: postcode.
	john := persons detect: [ :each | each address2 = address] ifNone: [nil].
	self assert: (john isNil).

	postcode := InlinedPostcode new code1: 'z2'; code2: '2aa'.
	john := persons detect: [ :each | each address2 postcode = postcode] ifNone: [nil].
	self assert: (john isNil).

	address := InlinedAddress new line1: '222222 some road'; postcode: postcode.
	john := persons detect: [ :each | each address2 = address] ifNone: [nil].
	self assert: (john isNil).
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test10TransactionUpdateFirstLevelInlined [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"Verify a regular update first"
	reStore evaluateAsTransaction: [daves first firstName: 'Davy'].
	reStore simulateReconnect.

	self assert: (daves isEmpty).
	daves := persons satisfying: [ :each | each firstName = 'Davy'].
	self assert: (daves first firstName = 'Davy').

	"First level inlined"
	reStore evaluateAsTransaction: [daves first address1 line1: '1a some road'].
	reStore simulateReconnect.
	self assert: (daves first address1 line1 = '1a some road')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test11TransactionUpdateSecondLevelInlined [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"Second level inlined"
	reStore evaluateAsTransaction: [daves first address1 postcode code1: 'nw1'].
	reStore simulateReconnect.

	self assert: (daves first address1 postcode code1 = 'nw1'). "changed" 
	self assert: (daves first address1 postcode code2 = '1aa'). "unchanged"

	reStore evaluateAsTransaction: [daves first address1 postcode code2: '11aa'].
	reStore simulateReconnect.

	self assert: (daves first address1 postcode code1 = 'nw1'). "unchanged" 
	self assert: (daves first address1 postcode code2 = '11aa')"changed"
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test12TransactionReplaceFirstLevelInlined [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"First level inlined"
	reStore evaluateAsTransaction: [daves first address1: (InlinedAddress new line1: '1a some road'; postcode: (InlinedPostcode new code1: 'z1'; code2: '1zz'))].
	reStore simulateReconnect.
	self assert: (daves first address1 line1 = '1a some road').
	self assert: (daves first address1 postcode code1 = 'z1').
	self assert: (daves first address1 postcode code2 = '1zz')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test13TransactionReplaceSecondLevelInlined [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"Second level inlined"
	reStore evaluateAsTransaction: [daves first address2 postcode: (InlinedPostcode new code1: 'z1'; code2: '1zz')].
	reStore simulateReconnect.
	self assert: (daves first address2 postcode code1 = 'z1').
	self assert: (daves first address2 postcode code2 = '1zz')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test15ManualUpdateFirstLevelInlined [

	| daves dave |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"Verify a regular update first"
	dave := daves first.
	dave firstName: 'dayve'.
	dave store.

	reStore simulateReconnect.
	daves := persons satisfying: [ :each | each firstName = 'dayve'].
	self assert: (daves first firstName = 'dayve').

	"First level inlined"
	dave := daves first.
	dave address1 line1: '123 some ave'.
	dave store.
	reStore simulateReconnect.

	self assert: (daves first address1 line1 = '123 some ave')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test16ManualUpdateSecondLevelInlined [

	| daves dave |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"Second level inlined"
	dave := daves first.
	dave address1 postcode code1: 'n16'. 
	dave store.
	reStore simulateReconnect.

	self assert: (daves first address1 postcode code1 = 'n16'). "changed"
	self assert: (daves first address1 postcode code2 = '1aa'). "unchanged"

	dave := daves first.
	dave address1 postcode code2: '16aa'. 
	dave store.
	reStore simulateReconnect.

	self assert: (daves first address1 postcode code1 = 'n16'). "unchanged"
	self assert: (daves first address1 postcode code2 = '16aa'). "unchanged"
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test17ManualReplaceFirstLevelInlined [

	| daves dave |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"First level inlined"
	dave := daves first address1: (InlinedAddress new line1: '1a some road'; postcode: (InlinedPostcode new code1: 'z1'; code2: '1zz')).
	dave store.
	reStore simulateReconnect.

	self assert: (daves first address1 line1 = '1a some road').
	self assert: (daves first address1 postcode code1 = 'z1').
	self assert: (daves first address1 postcode code2 = '1zz')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test18ManualReplaceSecondLevelInlined [

	| daves dave |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].

	"Second level inlined"
	dave := daves first.
	daves first address2 postcode: (InlinedPostcode new code1: 'z1'; code2: '1zz').
	dave store.
	reStore simulateReconnect.

	self assert: (daves first address2 postcode code1 = 'z1').
	self assert: (daves first address2 postcode code2 = '1zz')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test20ModifySimple [

	| daves |

	"Regular non-inlined"
	daves := persons satisfying: [ :each | each firstName = 'dayve'].
	daves modify: [ :each | each firstName: 'Dave'].

	reStore simulateReconnect.
	self assert: (daves isEmpty).
	
	daves := persons satisfying: [ :each | each firstName = 'Dave'].
	self assert: (daves size = 1).
	self assert: (daves first firstName = 'Dave')
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test21ModifyFirstLevelInlined [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].
	
	"First level inlined"
	daves modify: [ :each | each address1 line1: '987 some lane'].
	reStore simulateReconnect.

	self assert: (daves size = 1).
	self assert: (daves first firstName = 'Dave').
	self assert: (daves first line1 = 'dline1').
	self assert: (daves first address1 line1 = '987 some lane').

	persons modify: [ :each | each address2 line1: '456 some close'].
	reStore simulateReconnect.
	self assert: (persons size = 3).
	self assert: (persons allSatisfy: [ :each | each address2 line1 = '456 some close']).
	self assert: (persons allSatisfy: [ :each | each line1 ~= '456 some close'])
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test22ModifySecondLevelInlined [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].
	
	"Second level inlined"
	daves modify: [ :each | each address1 postcode code1: 'x99'].
	reStore simulateReconnect.

	self assert: (daves size = 1).
	self assert: (daves first firstName = 'Dave').
	self assert: (daves first code1 = 'dcode1').
	self assert: (daves first address1 postcode code1 = 'x99').
	self assert: (daves first address1 postcode code2 ~= 'x99').

	persons modify: [ :each | each address2 postcode code2: '9xx'].
	reStore simulateReconnect.

	self assert: (persons size = 3).
	self assert: (persons allSatisfy: [ :each | each address2 postcode code2 = '9xx']).
	self assert: (persons allSatisfy: [ :each | each address2 postcode code1 ~= '9xx']).
	self assert: (persons allSatisfy: [ :each | each code1 ~= '9xx']).
]

{ #category : #'unit tests' }
SSWReStoreInlinedTest >> test23ModifyDisambiguation [

	| daves |

	daves := persons satisfying: [ :each | each firstName = 'Dave'].
	
	daves modify: [ :each | each line1: 'dline1_mod'].
	reStore simulateReconnect.

	self assert: (daves size = 1).
	self assert: (daves first firstName = 'Dave').
	self assert: (daves first line1 = 'dline1_mod').
	self assert: (daves first address1 line1 = '1 some st').

	persons modify: [ :each | each code1: 'code1_mod'].
	reStore simulateReconnect.

	self assert: (persons size = 3).
	self assert: (persons allSatisfy: [ :each | each code1 = 'code1_mod']).
	self assert: (persons allSatisfy: [ :each | each address2 postcode code1 ~= 'code1_mod']).
	self assert: (persons allSatisfy: [ :each | each address2 postcode code1 ~= '456 some close']).
]
