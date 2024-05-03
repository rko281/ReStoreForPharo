"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreGenericObjectTest,
	#superclass : #SSWReStoreGenericTest,
	#instVars : [
		'component'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreGenericObjectTest class >> isAbstract [

	^self == SSWReStoreGenericObjectTest
]

{ #category : #helpers }
SSWReStoreGenericObjectTest >> _testComponentExistenceOnDependency [

	"No dependency at this level so should still exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) notNil.

	reStore simulateReconnect.
	self assert: ((component class storedInstancesIn: reStore) detect: [ :each | each name = component name] ifNone: [nil]) notNil
]

{ #category : #public }
SSWReStoreGenericObjectTest >> fetchTestObjects [

	super fetchTestObjects.

	component := testObject component
]

{ #category : #accessing }
SSWReStoreGenericObjectTest >> templateTestObject [

	^GenericTest new
		component: self templateComponent;
		yourself
]

{ #category : #'unit tests' }
SSWReStoreGenericObjectTest >> testDependencyCascadedDelete [

	"Check that inst var contents are or are not deleted when the owning object is deleted, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	testObject unstore.

	"Verify the delete"
	self assert: (testObject class storedInstancesIn: reStore) isEmpty.

	self _testComponentExistenceOnDependency
]

{ #category : #'unit tests' }
SSWReStoreGenericObjectTest >> testDependencyDeleteOnReplacement [

	"Check that non-dependent inst var contents are or are not deleted when replaced, as appropriate for the specified relationship (i.e. delete if dependent, otherwise not)"

	testObject component: nil.
	testObject store.

	self _testComponentExistenceOnDependency
]
