Class {
	#name : #SSWDBDirectlyPersistedObject,
	#superclass : #Object,
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWDBDirectlyPersistedObject class >> fromReStoreValue: aValue [

	"Return an instance of the receiver generated from aValue (an instance of the receiver's reStoreValueClass)"

	^self subclassResponsibility
]

{ #category : #testing }
SSWDBDirectlyPersistedObject class >> hasMutablePersistentInstances [

	"Are instances of this class mutable (at least from the database's point of view)"

	^false
]

{ #category : #'instance creation' }
SSWDBDirectlyPersistedObject class >> instanceFromDBValue: aValue in: aReStore [

	"Return an instance of the receiver generated from aValue (an instance of the receiver's reStoreValueClass) read from aReStore"

	"Ususally aReStore is irrelevant"
	^self fromReStoreValue: aValue
]

{ #category : #testing }
SSWDBDirectlyPersistedObject class >> isDirectlyPersisted [

	^true
]

{ #category : #persistency }
SSWDBDirectlyPersistedObject class >> reStoreInstVarAccessor [

	^self hasMutablePersistentInstances
		ifTrue: [SSWMutableInstVarAccessor new]
		ifFalse: [super reStoreInstVarAccessor]
]

{ #category : #accessing }
SSWDBDirectlyPersistedObject class >> reStoreValueClass [

	"Return the class of object of which instances of the receiver are persisted in the database, i.e. the class of an instance's reStoreValue"

	^self subclassResponsibility
]

{ #category : #printing }
SSWDBDirectlyPersistedObject class >> writeSQLTypeOn: aStream using: anSQLDialect [

	self reStoreValueClass writeSQLTypeOn: aStream using: anSQLDialect
]

{ #category : #public }
SSWDBDirectlyPersistedObject >> <= anObject [

	"Directly persisted objects should always be compared based on their reStoreValue"

	^self reStoreValue <= anObject reStoreValue
]

{ #category : #comparing }
SSWDBDirectlyPersistedObject >> = anObject [

	"Directly persisted objects should always be compared based on their reStoreValue"

	^self reStoreValue = anObject reStoreValue
]

{ #category : #comparing }
SSWDBDirectlyPersistedObject >> hash [

	^self reStoreValue hash
]

{ #category : #testing }
SSWDBDirectlyPersistedObject >> isValidForPersistence [

	^true
]

{ #category : #accessing }
SSWDBDirectlyPersistedObject >> reStoreValue [

	"Return the value used to represent the receiver in the database.
	Should be an instance of this class's reStoreValueClass"

	^self subclassResponsibility
]
