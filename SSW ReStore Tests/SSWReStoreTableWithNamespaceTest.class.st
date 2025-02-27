Class {
	#name : 'SSWReStoreTableWithNamespaceTest',
	#superclass : 'SSWReStoreTableTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreTableWithNamespaceTest class >> addDatabaseNameTo: aClassDef [

	aClassDef namespace: SSWReStoreTableWithNamespaceTest namespace
]

{ #category : 'public' }
SSWReStoreTableWithNamespaceTest class >> namespace [

	^'test_namespace'
]

{ #category : 'running' }
SSWReStoreTableWithNamespaceTest >> _test31CrossNamespaceSetup [

	| tables namespaceTables persons |

	tables := reStore connection tables.
	namespaceTables := reStore connection tablesInNamespace: self namespace.
	self deny: (tables includes: 'simple_person').
	self assert: (tables includes: 'simple_address').

	self assert: (namespaceTables includes: 'simple_person').
	self deny: (namespaceTables includes: 'simple_address').

	persons := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	persons do: [ :each | each address: (SimpleAddress new line1: 'p', each _id displayString)].
	persons storeAll.

	reStore simulateReconnect
]

{ #category : 'running' }
SSWReStoreTableWithNamespaceTest >> addClassesTo: aReStore [

	super addClassesTo: aReStore.

	reStore connection createNamespace: self namespace
]

{ #category : 'constants' }
SSWReStoreTableWithNamespaceTest >> namespace [

	^self class namespace
]

{ #category : 'running' }
SSWReStoreTableWithNamespaceTest >> releaseReStore: aReStore [

	reStore connection dropNamespace: self namespace.
	super releaseReStore: aReStore
]

{ #category : 'running' }
SSWReStoreTableWithNamespaceTest >> setUp [

	{SimplePerson. SimplePerson2. SuperPerson} do: [ :cls | self addMethod: self class class>>#addDatabaseNameTo: withSelector: #addClassDefinitionTo: toClass: cls class].

	super setUp
]

{ #category : 'running' }
SSWReStoreTableWithNamespaceTest >> tearDown [

	{SimplePerson. SimplePerson2. SuperPerson} do: [ :cls | self removeSelector: #addClassDefinitionTo: fromClass: cls class].

	"Error trap superclass implementation primarily for SQLite which drops attached database on reconnect, leading to 'table not found' errors in destroyAllClasses"
	[super tearDown] on: reStore connection dbErrorClass do: [ :exc | ('*no such table*' match: exc description) ifTrue: [exc return] ifFalse: [exc pass]]
]

{ #category : 'unit tests' }
SSWReStoreTableWithNamespaceTest >> test00VerifyNamespace [

	| tables namespaceTables |

	tables := reStore connection tables.
	namespaceTables := reStore connection tablesInNamespace: self namespace.
	self deny: (tables includes: 'simple_person').
	self deny: (tables includes: 'super_person').
	self assert: (tables includes: 'simple_address').

	self assert: (namespaceTables includes: 'simple_person').
	self assert: (namespaceTables includes: 'super_person').
	self deny: (namespaceTables includes: 'simple_address')
]

{ #category : 'unit tests' }
SSWReStoreTableWithNamespaceTest >> test02RenameClass [

	"Ensure the renamed class doesn't exist in the standard namespace - various attempts to accomodate different dialects"
	[reStore connection exec: 'drop table if exists simple_person2'] on: reStore connection dbErrorClass do: [ :exc | [reStore connection exec: 'drop table simple_person2'] on: reStore connection dbErrorClass do: [ :exc2 | exc2 return]].

	super test02RenameClass.

	"Verify renamed table is in the correct namespace"
	self deny: (reStore connection tables includes: 'simple_person2').
	self assert: ((reStore connection tablesInNamespace: self namespace) includes: 'simple_person2')
]

{ #category : 'unit tests' }
SSWReStoreTableWithNamespaceTest >> test31CrossNamespaceLinking [

	| persons |

	self _test31CrossNamespaceSetup.

	persons := (SimplePerson storedInstancesIn: reStore) asOrderedCollection.
	self assert: (persons allSatisfy: [ :each | each address line1 = ('p', each _id displayString)])
]

{ #category : 'unit tests' }
SSWReStoreTableWithNamespaceTest >> test32CrossNamespaceQuerying [

	| persons |

	self _test31CrossNamespaceSetup.

	persons := SimplePerson storedInstancesIn: reStore.
	self assert: (persons detect: [ :each | each _id = 5]) address line1 equals: 'p5'.
	self assert: (persons detect: [ :each | each address line1 = 'p2']) _id = 2.
]
