"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreGenericTest',
	#superclass : 'SSWReStore2Test',
	#instVars : [
		'testObject',
		'testObject2'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreGenericTest class >> isAbstract [

	^self == SSWReStoreGenericTest
]

{ #category : 'running' }
SSWReStoreGenericTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.

	GenericTest componentDefinition: self componentDefinition.
	aReStore addClass: GenericTest
]

{ #category : 'accessing' }
SSWReStoreGenericTest >> componentDefinition [

	^self subclassResponsibility
]

{ #category : 'running' }
SSWReStoreGenericTest >> createTestData [

	self createTestObject.

	self fetchTestObjects
]

{ #category : 'running' }
SSWReStoreGenericTest >> createTestObject [

	reStore evaluateAsTransaction: [self templateTestObject storeIn: reStore]
]

{ #category : 'running' }
SSWReStoreGenericTest >> destroyAllData [

	"GenericTest>>component can change definition; ReStore doesn't check for this so drop any contained tables"
	((reStore tableForClass: GenericTest) collectionAccessing: #component) ifNotNil: 
		[ :collection | 
		collection containedTables isEmpty ifFalse: 
			[collection containedTables do: [ :table | reStore executeSQLAsTxn: {'drop table if exists ', table name. 'delete from next_id where table_name = <1p>' << table name}]]].

	super destroyAllData
]

{ #category : 'running' }
SSWReStoreGenericTest >> fetchTestObjects [

	(Delay forMilliseconds: 10) wait.
	reStore simulateReconnect.

	testObject := (GenericTest storedInstancesIn: reStore) first
]

{ #category : 'running' }
SSWReStoreGenericTest >> setUp [

	super setUp.

	testObject2 := (GenericTest storedInstancesIn: reStore2) first
]

{ #category : 'accessing' }
SSWReStoreGenericTest >> templateComponent [

	"Ensure unique name"
	(Delay forMicroseconds: 10) wait.

	^GenericOwnedTest new name: (self class name, Time microsecondClockValue printString)
]

{ #category : 'accessing' }
SSWReStoreGenericTest >> templateTestObject [

	^self subclassResponsibility
]

{ #category : 'tests' }
SSWReStoreGenericTest >> testReadAllStatementNilled [

	"Verify the cached readAllStatement is nilled when necessary (previously omitted for non-collections)"

	| persons table |

	persons := (GenericTest storedInstancesIn: reStore) asOrderedCollection.
	persons fetchAll: #(#component).

	reStore reconnect.

	table := reStore tableForClass: GenericTest.
	self assert: (table componentAccessing: #component) _readAllStatement isNil
]
