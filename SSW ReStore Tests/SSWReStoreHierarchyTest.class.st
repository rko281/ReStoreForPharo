"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreHierarchyTest,
	#superclass : #SSWReStoreTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #running }
SSWReStoreHierarchyTest >> addClassesTo: aReStore [

	aReStore
		addClassWithSubclasses: SuperPerson
]

{ #category : #running }
SSWReStoreHierarchyTest >> createTestData [

	(Array
		with: (SuperPerson new firstName: 'john')
		with: (MidPerson new firstName: 'dave'; middleName: 'davison')
		with: (SubPerson new firstName: 'mike'; middleName: 'michaelson'; age: 22)) storeAllIn: reStore.

	reStore simulateReconnect
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test01VerifySetUp [
	self assert: ((SuperPerson storedInstancesIn: reStore ) size = 3)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test02Counts [

	| insts |

	insts := SuperPerson storedInstancesIn: reStore.
	self assert: (insts size = 3).

	insts := (SuperPerson storedInstancesIn: reStore ) withoutInheritance.
	self assert: (insts size = 1).

	insts := MidPerson storedInstancesIn: reStore.
	self assert: (insts size = 2).

	insts := (MidPerson storedInstancesIn: reStore) withoutInheritance.
	self assert: (insts size = 1).

	insts := SubPerson storedInstancesIn: reStore.
	self assert: (insts size = 1).

	insts := (SubPerson storedInstancesIn: reStore) withoutInheritance.
	self assert: (insts size = 1)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test03Querying [

	"Querying for actual aspects"

	| persons midPersons subPersons |

	persons := SuperPerson storedInstancesIn: reStore.
	midPersons := MidPerson storedInstancesIn: reStore.
	subPersons := SubPerson storedInstancesIn: reStore.
	
	self assert: ((persons satisfying: [ :each | each firstName = 'john']) size = 1).
	self assert: ((midPersons satisfying: [ :each | each firstName = 'john']) size = 0).
	self assert: ((subPersons satisfying: [ :each | each firstName = 'john']) size = 0).
	
	self assert: ((persons satisfying: [ :each | each firstName = 'dave']) size = 1).
	self assert: ((persons withoutInheritance satisfying: [ :each | each firstName = 'dave']) size = 0).
	self assert: ((midPersons satisfying: [ :each | each firstName = 'dave']) size = 1).
	self assert: ((subPersons satisfying: [ :each | each firstName = 'dave']) size = 0).

	self assert: ((persons satisfying: [ :each | each firstName = 'mike']) size = 1).
	self assert: ((persons withoutInheritance satisfying: [ :each | each firstName = 'mike']) size = 0).
	self assert: ((midPersons satisfying: [ :each | each firstName = 'mike']) size = 1).
	self assert: ((midPersons withoutInheritance satisfying: [ :each | each firstName = 'mike']) size = 0).
	self assert: ((subPersons satisfying: [ :each | each firstName = 'mike']) size = 1).
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test04Classes [

	"Test proxies respond correctly to class both with and without cached proxy"

	| insts john dave mike |

	insts := SuperPerson storedInstancesIn: reStore.
	
	john := insts detect: [ :e | e firstName = 'john'].
	self assert: john isDBProxy.
	self assert: (john class = SuperPerson).
	john _forgetProxiedObject.
	self assert: (john class = SuperPerson).

	dave := insts detect: [ :e | e firstName = 'dave'].
	self assert: dave isDBProxy.
	self assert: (dave class = MidPerson).
	dave _forgetProxiedObject.
	self assert: (dave class = MidPerson).
	self assert: (dave middleName = 'davison').

	mike := insts detect: [ :e | e firstName = 'mike'].
	self assert: mike isDBProxy.
	self assert: (mike class = SubPerson).
	mike _forgetProxiedObject.
	self assert: (mike class = SubPerson).
	self assert: (mike middleName = 'michaelson').
	self assert: (mike age = 22)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test05MidFirst [

	"Test a previously-erroring case where #first failed for mid and sub class collections (did not filter by class)"

	| midPersons |

	midPersons := MidPerson storedInstancesIn: reStore.
	self assert: ({MidPerson. SubPerson} includes: midPersons first class).
	self should: [(midPersons satisfying: [ :each | each firstName = 'john']) first] raise: Error
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test06SubFirst [

	"Test a previously-erroring case where #first failed for mid and sub class collections (did not filter by class)"

	| subPersons |

	subPersons := SubPerson storedInstancesIn: reStore.

	self assert: (subPersons first class = SubPerson).
	self should: [(subPersons satisfying: [ :each | each firstName = 'john']) first] raise: Error
]
