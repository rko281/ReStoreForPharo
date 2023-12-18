"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBInheritedTable,
	#superclass : #SSWDBTable,
	#instVars : [
		'classField'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #accessing }
SSWDBInheritedTable >> classField [

	"classField stores the DBField which defines which class of object a row represents.
	Note this is also a member of the receiver's controlFields (see setDefaultClassField) but is additionally held here
	a) for efficient access
	b) as a non-parameterizable field - class conditions are statically written into the receiver's SQL"
	
	^classField
]

{ #category : #accessing }
SSWDBInheritedTable >> classField: anSSWDBField [

	"classField stores the SSWDBField which defines which class of object a row represents.
	Note this is also a member of the receiver's controlFields (see setDefaultClassField)
	but is additionally held in this instance variable for efficient access"
	
	classField := anSSWDBField
]

{ #category : #defining }
SSWDBInheritedTable >> initializeClassField: aDBField [
	
	^aDBField
		table: self;
		accessor: SSWDBClassAccessor new;
		name: (self sqlDialect transformInstVarName: aDBField accessor nameInDB);
		targetClass: Metaclass;
		yourself
]

{ #category : #initializing }
SSWDBInheritedTable >> initializeIn: anSSWReStore [

	"Overriden to setup the classField"

	super initializeIn: anSSWReStore.
	self setDefaultClassField
]

{ #category : #'instance creation' }
SSWDBInheritedTable >> instanceClassFromRow: aDBRow [

	"Private - Determine the class to use from the row"
	
	^self classField convertValue: (aDBRow lookupField: self classField)
]

{ #category : #private }
SSWDBInheritedTable >> recoverExactClassInstanceFromRow: aDBRow into: anSSWDBObjectProxy [
	"Private - Recover assuming that aDBRow represents an object of exactly our instanceClass.
	Class has already been set on the proxy (see #recoverInstanceFromRow:into:"

	super recoverInstanceFromRow: aDBRow into: anSSWDBObjectProxy.
]

{ #category : #'instance creation' }
SSWDBInheritedTable >> recoverInstanceFromRow: aDBRow into: anSSWDBObjectProxy [
	"Redirect to the relevant concrete class, ensuring the proxy is informed of the actual class of the object.
	We must do this before setting the proxiedObject to ensure that the correct list of fields is used when
	initializing the copyObject.

	N.B. This should always be our instanceClass or a subclass thereof, never higher in the hierarchy.
	For leaf tables this means it should always be exactly our instanceClass, but this shared implementation is simpler."

	| class |
	class := self instanceClassFromRow: aDBRow.
	(class includesBehavior: self instanceClass) ifFalse: [self error:  'Proxy for <1d> retrieved a <2d> from the database.' << {self instanceClass. class}].
	anSSWDBObjectProxy _class: class.
	(class = self instanceClass ifTrue: [self] ifFalse: [self reStore tableForClass: class])
		recoverExactClassInstanceFromRow: aDBRow
		into: anSSWDBObjectProxy.
]

{ #category : #defining }
SSWDBInheritedTable >> setDefaultClassField [
	
	self controlFields add: (self initializeClassField: SSWDBStaticField new).
	self classField: (self initializeClassField: SSWDBNonParameterizedStaticField new)
]

{ #category : #evaluating }
SSWDBInheritedTable >> withAllFields [

	"Return a table equivalent to the receiver but containing all possible fields.	
	For an inherited table, need to include fields from table-sharing subclasses"

	| withAllFields |

	withAllFields := self copy.
	withAllFields dataFields: self dataFields copy.

	self instanceClass subclassesInheritingPersistency do:
		[ :cls || table |
		table := self reStore tableForClass: cls.
		table dataFields do: 
			[ :field | 
			(withAllFields hasFieldAccessing: field accessor name) ifFalse: 
				[withAllFields dataFields add: field]]].
	
	^withAllFields
]
