Extension { #name : 'Object' }

{ #category : '*SSW ReStore Base Additions' }
Object >> _instVarAt: anInteger [

	"Make the receiver polymorphic with proxies"
	
	^self instVarAt: anInteger
]

{ #category : '*SSW ReStore Base Additions' }
Object >> _instVarAt: anInteger put: anObject [

	"Make the receiver polymorphic with proxies"
	
	^self instVarAt: anInteger put: anObject
]

{ #category : '*SSW ReStore Base Additions' }
Object >> chainPerform: aCollection [

	"perform: each member (Symbol) of aCollection against the receiver as a chain
	i.e. the second Symbol is perform:'d against the result of perform:ing the first, etc."

	^aCollection inject: self into: [ :receiver :symbol | receiver perform: symbol]

]

{ #category : '*SSW ReStore Base Additions' }
Object class >> hasMutablePersistentInstances [

	"Are instances of this class mutable (at least from the database's point of view), i.e. can have their internal state changed.
	false by default; subclasses who have this behaviour should override

	ASSERT: self isDirectlyPersistedNonBaseClass - not relevant to normal persistent application classes (those having reStoreDefinition)"

	^false
]

{ #category : '*SSW ReStore Base Additions' }
Object >> includedIn: aCollection [

	"Reciprocal of Collection>>includes: "

	^aCollection includes: self
]

{ #category : '*SSW ReStore Base Additions' }
Object class >> isDirectlyPersisted [

	"Return whether the receiver class is directly persisted in the database, i.e. has a representation that it stored in a single database column.
	Default - the persistent base classes. 

	Other classes which can provide such a representation of themselves can return true but must also implement certain other methods
	- see SSWDBDirectlyPersistedObject which may be used as a superclass for such classes"

	^self isPersistentBaseClass
]

{ #category : '*SSW ReStore Base Additions' }
Object class >> isDirectlyPersistedNonBaseClass [

	"Return whether the receiver class is directly persisted in the database, i.e. has a representation that it stored in a single database column BUT is not one of the persistent base classes"

	^self isPersistentBaseClass not and: [self isDirectlyPersisted]
]

{ #category : '*SSW ReStore Base Additions' }
Object class >> isMutableDirectlyPersistedNonBaseClass [

	"Return whether the receiver class is directly persisted in the database, i.e. has a representation that it stored in a single database column BUT is not one of the persistent base classes AND can be mutated (have its internal state changed)"

	^self isDirectlyPersistedNonBaseClass and: [self hasMutablePersistentInstances]
]

{ #category : '*SSW ReStore Base Additions' }
Object class >> isPersistentBaseClass [

	"Return whether the receiver class is a valid persistent base class
	 - a class which can be represented in the DB by a single field type, rather than a table.

	false by default, subclasses which are so valid may override"

	^false
]
