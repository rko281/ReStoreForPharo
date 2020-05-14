"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreTableTest,
	#superclass : #SSWReStorePersonTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreTableTest >> createTestData [

	| people detailedPeople |
	
	reStore 
		addClass: SimplePerson2;
		destroyClass: SimplePerson2;
		forgetClass: SimplePerson2.

	reStore destroyAllClasses; synchronizeAllClasses.

	SimplePerson2 
		useForename: false;
		useBestFriend: false;
		useNotes: false.

	DetailedPerson2 
		useDateOfBirth: false;
		useBestFriend: false;
		useLongNotes: false.

	reStore destroyAllClasses.
	reStore synchronizeAllClasses.

	people := (1 to: self sampleSize) collect: 
		[ :e | 
		SimplePerson new 
			surname: 'Smith'; 
			firstName: 'John'; 
			emailAddress: 'john@something'; 
			friend: (SimplePerson new surname: 'Jones'; firstName: 'Sam'; yourself);
			yourself].

	detailedPeople := (1 to: self sampleSize) collect: 
			[ :e | 
			(SuperPerson new)
				surname: 'Smith';
				firstName: 'John';
				yourself].

	detailedPeople := detailedPeople asOrderedCollection.
	detailedPeople addAll: 
		((1 to: self sampleSize) collect: 
			[ :e | 
			(DetailedPerson new)
				surname: 'Smith';
				firstName: 'John';
				dob: (Date newDay: 1 monthIndex: 1 year: 1970);
				friend: (DetailedPerson new surname: 'Jones'; firstName: 'Sam');
				yourself]).

	detailedPeople
		add: 
			(SuperPerson new
				firstName: 'James';
				surname: 'Smith';
				yourself);
		add: 
			(DetailedPerson new
				firstName: 'James';
				surname: 'Smith';
				yourself);
		add: 
			(DetailedPerson new
				firstName: 'Peter';
				surname: 'Smith';
				yourself).

	reStore beginTransaction.
	people do: [:e | e storeIn: reStore].
	detailedPeople do: [:e | e storeIn: reStore].
	reStore commitTransaction.

	reStore simulateReconnect
]

{ #category : #helpers }
SSWReStoreTableTest >> ensureHierarchyColumnsAllPresent [

	| table columns expected |

	reStore addClassWithSubclasses: SuperPerson.
	table := (reStore tableForClass: SuperPerson) forCreation.

	columns := (reStore connection _columnsInTable: table) collect: [ :each | each name].
	expected := table allFields collect: [ :each | each name].

	self assert: (expected allSatisfy: [ :each | columns includes: each])
]

{ #category : #helpers }
SSWReStoreTableTest >> renameClass [

	reStore renamedClass: SimplePerson2 from: #SimplePerson.

	"Since this is a faked rename (substituting one class for another) we need to manually tidy up the table cache"
	reStore tableCache removeKey: SimplePerson
]

{ #category : #helpers }
SSWReStoreTableTest >> renameDetailedClass [

	reStore renamedClass: DetailedPerson2 from: #DetailedPerson.

	"Since this is a faked rename (substituting one class for another) we need to manually tidy up the table cache"
	reStore tableCache removeKey: DetailedPerson
]

{ #category : #constants }
SSWReStoreTableTest >> renamedTableName [

	^'SIMPLE_PERSON2'
]

{ #category : #constants }
SSWReStoreTableTest >> sampleSize [

	^10
]

{ #category : #Running }
SSWReStoreTableTest >> setUp [

	DetailedPerson2 
		useDateOfBirth: false; 
		useLongNotes: false; 
		useBestFriend: false.

	super setUp
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test01VerifySetup [

	self assert: ((SimplePerson storedInstancesIn: reStore) size = (self sampleSize * 2))
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test02RenameClass [

	| people table |

	self renameClass.

	people := SimplePerson2 storedInstancesIn: reStore.

	self assert: (people size = (self sampleSize * 2)).
	self assert: (people anySatisfy: [ :each | each firstName = 'John']).
	self assert: (people anySatisfy: [ :each | each firstName = 'Sam']).

	table := reStore tableForClass: SimplePerson2.
	self assert: (((SSWDBTableRecord storedInstancesIn: reStore) detect: [ :seq | seq tableName = table name]) nextID >= (self sampleSize + 1))
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test03RenameInstVar [

	| people |

	self renameClass.

	SimplePerson2 useForename: true.
	reStore renamedInstVar: #forename from: #firstName in: SimplePerson2.

	people := SimplePerson2 storedInstancesIn: reStore.

	self assert: (people anySatisfy: [ :each | each forename = 'John']).
	self assert: (people anySatisfy: [ :each | each forename = 'Sam']).


]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test04RenameInstVarPersistent [

	| people |

	self renameClass.

	SimplePerson2 useBestFriend: true.
	reStore renamedInstVar: #bestFriend from: #friend in: SimplePerson2.

	people := SimplePerson2 storedInstancesIn: reStore.

	self assert: ((people detect: [ :each | each firstName = 'John']) bestFriend firstName = 'Sam')
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test06ChangeInstVarClass [

	| table originalSize origField people |

	SimplePerson2 useNotes: true; useLongNotes: false.
	table := reStore addClass: SimplePerson2.
	reStore destroyClass: SimplePerson2; synchronizeClass: SimplePerson2.

	originalSize := SimplePerson2 notesSize.
	origField := (reStore columnsInTable: table) detect: [ :each | each name asUppercase = 'NOTES'].
	self assert: (origField precision = originalSize).

	people := (1 to: 10) collect: 
		[ :index || char |
		char := Character digitValue: (index + 9).
		SimplePerson2 new 
			surname: $B asString; 
			notes: ((String new: originalSize) atAllPut: char);
			yourself].

	people storeAllIn: reStore.
	reStore simulateReconnect.

	SimplePerson2 useLongNotes: true.
	self assert: (SimplePerson2 notesSize > originalSize).

	reStore changedClassOfInstVar: #notes in: SimplePerson2 modifyUsing: 
		[ :each | each notes, 'longer'].

	people := (SimplePerson2 storedInstancesIn: reStore) asOrderedCollection.
	self assert: (people allSatisfy: [ :each | (each notes size > originalSize) and: [each notes endsWith: 'longer']])
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test07AlterInstVar [

	| table originalSize origField people newSize |

	SimplePerson2 useNotes: true; useLongNotes: false.
	table := reStore addClass: SimplePerson2.
	reStore destroyClass: SimplePerson2; synchronizeClass: SimplePerson2.

	originalSize := SimplePerson2 notesSize.
	origField := (reStore columnsInTable: table) detect: [ :each | each name asUppercase = 'NOTES'].
	self assert: (origField precision = originalSize).

	people := (1 to: 10) collect: 
		[ :index || char |
		char := Character digitValue: (index + 9).
		SimplePerson2 new 
			surname: char asString; 
			notes: ((String new: originalSize) atAllPut: char);
			yourself].

	people storeAllIn: reStore.
	reStore simulateReconnect.

	SimplePerson2 useLongNotes: true.
	self assert: (SimplePerson2 notesSize > originalSize).

	reStore alterInstVar: #notes in: SimplePerson2.

	"Verify no data loss"
	self assert: ((SimplePerson2 storedInstancesIn: reStore) asOrderedCollection allSatisfy: [ :each | (each notes size = originalSize) and: [each notes allSatisfy: [ :char | char = each surname first]]]).

	"Verify the size has been increased"
	newSize := SimplePerson2 notesSize.
	self assert: newSize > originalSize.
	people := (SimplePerson2 storedInstancesIn: reStore) asOrderedCollection.
	people do: [ :each | each notes: ((String new: newSize) atAllPut: each surname first; yourself)].
	people storeAll.

	reStore simulateReconnect.
	self assert: ((SimplePerson2 storedInstancesIn: reStore) asOrderedCollection allSatisfy: [ :each | (each notes size = newSize) and: [each notes allSatisfy: [ :char | char = each surname first]]])
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test09DestroyTable [

	| table |

	table := reStore tableForClass: SimplePerson2.

	reStore destroyClass: SimplePerson2.

	self deny: (reStore dbIncludesTable: table)
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test11VerifySetup [

	self assert: (SuperPerson storedInstancesIn: reStore) size = ((self sampleSize * 3) + 3). "1 x super + 2 x Detailed + (1 custom super + 2 custom detailed)" 
	self assert: (SuperPerson storedInstancesIn: reStore) withoutInheritance size = (self sampleSize + 1) "+1 custom super".
	self assert: (DetailedPerson storedInstancesIn: reStore) size = ((self sampleSize * 2) + 2) "+2 custom detailed"
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test12Unstore [

	self assert: (((SuperPerson storedInstancesIn: reStore) satisfying: [ :each | each firstName = 'James']) size = 2).
	self assert: (((DetailedPerson storedInstancesIn: reStore) satisfying: [ :each | each firstName = 'James']) size = 1).
	self assert: (((SuperPerson storedInstancesIn: reStore) satisfying: [ :each | each firstName = 'Peter']) size = 1).

	self assert: (((SuperPerson storedInstancesIn: reStore) unstore: [ :each | each firstName = 'James']) = 2).
	self assert: (((DetailedPerson storedInstancesIn: reStore) unstore: [ :each | each firstName = 'Peter']) = 1).

	self assert: (((SuperPerson storedInstancesIn: reStore) satisfying: [ :each | each firstName = 'James']) isEmpty).
	self assert: (((SuperPerson storedInstancesIn: reStore) satisfying: [ :each | each firstName = 'Peter']) isEmpty).
	self assert: ((SuperPerson storedInstancesIn: reStore) size = (self sampleSize * 3)).
	self assert: ((SuperPerson storedInstancesIn: reStore) withoutInheritance size = self sampleSize).
	self assert: ((DetailedPerson storedInstancesIn: reStore) size = (self sampleSize * 2)).

]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test13RenameClassHierarchy [

	| people table |

	DetailedPerson2 useDateOfBirth: false.
	self renameDetailedClass.

	people := DetailedPerson2 storedInstancesIn: reStore.

	self assert: (people size = ((self sampleSize * 2) + 2)).
	self assert: (people anySatisfy: [ :each | each firstName = 'John']).
	self assert: (people anySatisfy: [ :each | each firstName = 'Sam']).

	table := reStore tableForClass: DetailedPerson2.
	self assert: (((SSWDBTableRecord storedInstancesIn: reStore) detect: [ :seq | seq tableName = table name]) nextID >= (self sampleSize + 1)).

	self ensureHierarchyColumnsAllPresent
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test14RenameInstVarHierarchy [

	| people |

	self renameDetailedClass.

	DetailedPerson2 useDateOfBirth: true.
	reStore renamedInstVar: #dateOfBirth from: #dob in: DetailedPerson2.

	people := DetailedPerson2 storedInstancesIn: reStore.

	self assert: (people anySatisfy: [ :each | each dateOfBirth = (Date newDay: 1 monthIndex: 1 year: 1970)]).

	self ensureHierarchyColumnsAllPresent
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test15RenameInstVarPersistentHierarchy [

	| people |

	self renameDetailedClass.

	DetailedPerson2 useBestFriend: true.
	reStore renamedInstVar: #bestFriend from: #friend in: DetailedPerson2.

	people := DetailedPerson2 storedInstancesIn: reStore.

	self assert: ((people detect: [ :each | each firstName = 'John']) bestFriend firstName = 'Sam').

	self ensureHierarchyColumnsAllPresent
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test16ChangeInstVarClassHierarchy [

	| table originalSize origField people |

	self renameDetailedClass.

	DetailedPerson2 useLongNotes: false.
	reStore addClassWithSubclasses: SuperPerson.
	table := reStore tableForClass: DetailedPerson2.
	reStore destroyClass: SuperPerson; synchronizeClass: SuperPerson.

	originalSize := DetailedPerson2 notesSize.
	origField := (reStore columnsInTable: table) detect: [ :each | each name asUppercase = 'NOTES'].
	self assert: (origField precision = originalSize).

	people := (1 to: 10) collect: 
		[ :index || char |
		char := Character digitValue: (index + 9).
		DetailedPerson2 new 
			surname: char asString; 
			notes: ((String new: originalSize) atAllPut: char);
			yourself].

	people storeAllIn: reStore.

	self refreshDelay.

	DetailedPerson2 useLongNotes: true.
	self assert: (DetailedPerson2 notesSize > originalSize).

	reStore changedClassOfInstVar: #notes in: DetailedPerson2 modifyUsing: 
		[ :each | each notes, 'xxx xxx xxx longer'].

	self assert: ((DetailedPerson2 storedInstancesIn: reStore) asOrderedCollection allSatisfy: [ :each | (each notes size > originalSize) and: [each notes endsWith: 'longer']]).

	self ensureHierarchyColumnsAllPresent
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test17AlterInstVarHierarchy [

	| table originalSize origField people newSize |

	self renameDetailedClass.

	DetailedPerson2 useLongNotes: false.
	reStore addClassWithSubclasses: SuperPerson.
	table := reStore tableForClass: DetailedPerson2.
	reStore destroyClass: SuperPerson; synchronizeClass: SuperPerson.

	originalSize := DetailedPerson2 notesSize.
	origField := (reStore columnsInTable: table) detect: [ :each | each name asUppercase = 'NOTES'].
	self assert: (origField precision = originalSize).

	people := (1 to: 10) collect: 
		[ :index || char |
		char := Character digitValue: (index + 9).
		DetailedPerson2 new 
			surname: char asString; 
			notes: ((String new: originalSize) atAllPut: char);
			yourself].

	people storeAllIn: reStore.

	reStore simulateReconnect.

	DetailedPerson2 useLongNotes: true.
	self assert: (DetailedPerson2 notesSize > originalSize).
	reStore alterInstVar: #notes in: DetailedPerson2.

	"Verify no data loss"
	self assert: ((DetailedPerson2 storedInstancesIn: reStore) asOrderedCollection allSatisfy: [ :each | (each notes size = originalSize) and: [each notes allSatisfy: [ :char | char = each surname first]]]).

	"Verify the size has been increased"
	newSize := DetailedPerson2 notesSize.
	self assert: newSize > originalSize.
	people := (DetailedPerson2 storedInstancesIn: reStore) asOrderedCollection.
	people do: [ :each | each notes: ((String new: newSize) atAllPut: each surname first; yourself)].
	people storeAll.

	reStore simulateReconnect.
	self assert: ((DetailedPerson2 storedInstancesIn: reStore) asOrderedCollection allSatisfy: [ :each | (each notes size = newSize) and: [each notes allSatisfy: [ :char | char = each surname first]]]).

	self ensureHierarchyColumnsAllPresent
]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test19DestroyTable [

	self renameDetailedClass.
	reStore destroyClass: DetailedPerson2.
	self assert: (SuperPerson storedInstancesIn: reStore) size = (self sampleSize + 1)

]

{ #category : #'unit tests' }
SSWReStoreTableTest >> test20QueryRelatedHierarchy [

	"Issue 120-015"

	reStore 
		addClassWithSubclasses: SuperPerson;
		destroyAllClasses;
		synchronizeAllClasses.

	reStore evaluateAsTransaction: 
		[DetailedPerson1 new
			surname:'Smith'; firstName: 'John';friend2:
				(DetailedPerson2 new
					surname:'Jones'; firstName: 'Bill';yourself);
			storeIn: reStore].

	self assert: ((SuperPerson storedInstancesIn: reStore) size = 2).
	self assert: ((DetailedPerson1 storedInstancesIn: reStore) size = 1).
	self assert: ((DetailedPerson2 storedInstancesIn: reStore) size = 1).

	self assert: (((DetailedPerson1 storedInstancesIn: reStore) select: [ :e | 'Jon*' match: e friend2 surname]) size = 1).
	self assert: (((DetailedPerson1 storedInstancesIn: reStore) detect: [ :e | 'Jon*' match: e friend2 surname]) firstName = 'John')
]
