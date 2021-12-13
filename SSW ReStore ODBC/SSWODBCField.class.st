Class {
	#name : #SSWODBCField,
	#superclass : #ODBCField,
	#instVars : [
		'statement',
		'needsRebinding'
	],
	#category : #'SSW ReStore ODBC'
}

{ #category : #'instance creation' }
SSWODBCField class >> newForCol: aColAttr statement: anSSWODBCStatement [

	^(self newForCol: aColAttr)
		statement: anSSWODBCStatement;
		yourself
]

{ #category : #initialization }
SSWODBCField >> initializeForColumn: aDBColAttr [
	"Private - Initialize the receiver to represent a value from
	the database column described by the <DBColAttr> argument.
	Answer the receiver."

	lengthBuf := SQLLEN fromInteger: SQL_NULL_DATA.
	column := aDBColAttr.
	buffer := ByteArray new: aDBColAttr lengthC.
	bufferSize := aDBColAttr lengthC.
	needsRebinding := false.
	^self
]

{ #category : #accessing }
SSWODBCField >> needsRebinding [
	^needsRebinding
]

{ #category : #accessing }
SSWODBCField >> needsRebinding: anObject [
	needsRebinding := anObject
]

{ #category : #converting }
SSWODBCField >> numberToNumeric: aNumberOrBoolean [

	"Overridden to allow Numeric-based Booleans"

	| aNumber |

	(aNumberOrBoolean == true or: [ aNumberOrBoolean == false ] ) 
	ifTrue: 
		[aNumberOrBoolean 
			ifTrue: [aNumber := self sqlDialect trueObject]
			ifFalse: [aNumber := self sqlDialect falseObject]]
	ifFalse:
		[aNumber := aNumberOrBoolean].
	
	(self shouldTranslate: aNumber class: Number) 	ifTrue: 
			[self setAnsiString: ((aNumber asScaledDecimal: column scale) printShowingDecimalPlaces: column scale )]
]

{ #category : #converting }
SSWODBCField >> setAnsiString: aStringOrObject [

	"Overridden to:
	 - automatically truncate oversize Strings
	 - allow String-based objects (Date, Boolean etc.)"

	aStringOrObject isString
	ifTrue: 
		[(column isFunctionParameter not and: [aStringOrObject  size > (buffer size - 1) "for null terminator"])
		ifTrue: 
			[Notification signal: 'ReStore: oversized String truncated'. 
			super setAnsiString: (aStringOrObject  copyFrom: 1 to: (buffer size - 1))]
		ifFalse: 
			[super setAnsiString: aStringOrObject ]]
	ifFalse: 
		[super setAnsiString: (aStringOrObject sqlStringIn: self sqlDialect)]
]

{ #category : #converting }
SSWODBCField >> setByte: aNumberOrBoolean [

	"Overridden to allow Integer-based Booleans"

	(aNumberOrBoolean isKindOf: Boolean) 
	ifTrue: 
		["self assert: [self sqlDialect trueObject isKindOf: Integer]"
		aNumberOrBoolean 
			ifTrue: [super setByte: self sqlDialect trueObject]
			ifFalse: [super setByte: self sqlDialect falseObject]]
	ifFalse:
		[super setByte: aNumberOrBoolean]
]

{ #category : #converting }
SSWODBCField >> setByteArray: aByteArrayOrOtherObject [

	"Coerce other classes (principally GUID/UUID)"

	super setByteArray: aByteArrayOrOtherObject asByteArray
]

{ #category : #converting }
SSWODBCField >> setDateAndTime: aDateAndTime [

	"Overridden to allow Date or Time (or another object implementing asDateAndTime) to be used"

	(aDateAndTime isKindOf: DateAndTime) 
		ifTrue: [super setDateAndTime: aDateAndTime]
		ifFalse: [super setDateAndTime: aDateAndTime asDateAndTime]
]

{ #category : #converting }
SSWODBCField >> setLong: aNumberOrBoolean [

	"Overridden to allow Integer-based Booleans"

	(aNumberOrBoolean isKindOf: Boolean) 
	ifTrue: 
		["self assert: [self sqlDialect trueObject isKindOf: Integer]"
		aNumberOrBoolean 
			ifTrue: [super setLong: self sqlDialect trueObject]
			ifFalse: [super setLong: self sqlDialect falseObject]]
	ifFalse:
		[super setLong: aNumberOrBoolean]
]

{ #category : #converting }
SSWODBCField >> setShort: aNumberOrBoolean [

	"Overridden to allow Integer-based Booleans"

	(aNumberOrBoolean isKindOf: Boolean) 
	ifTrue: 
		["self assert: [self sqlDialect trueObject isKindOf: Integer]"
		aNumberOrBoolean 
			ifTrue: [super setShort: self sqlDialect trueObject]
			ifFalse: [super setShort: self sqlDialect falseObject]]
	ifFalse:
		[super setShort: aNumberOrBoolean]
]

{ #category : #converting }
SSWODBCField >> setUtf16String: aStringOrObject [

	"Overridden to:
	 - automatically truncate oversize Strings
	 - allow String-based objects (Date, Boolean etc.)"

	aStringOrObject isString
	ifTrue: 
		[(column isFunctionParameter not and: [aStringOrObject byteSize > (buffer size - 1) "for null terminator"])
		ifTrue: 
			[Notification signal: 'ReStore: oversized String truncated'. 
			super setUtf16String: (aStringOrObject copyFrom: 1 to: ((buffer size - 2) // 2))]
		ifFalse: 
			[super setUtf16String: aStringOrObject]]
	ifFalse: 
		[super setUtf16String: (aStringOrObject asSQLStringIn: self sqlDialect) asUtf16String]
]

{ #category : #accessing }
SSWODBCField >> shouldTranslate: anObject class: aClass [

	"Override the superclass implementation to allow Booleans to masquerade as other classes
	 (some DBs do not offer direct BOOLEAN support)"

	(anObject class = SSWDBAllocatedID and: [aClass = Number]) ifTrue: [^true].

	^((anObject isKindOf: Boolean) and: [self sqlDialect trueObject class isKindOf: aClass])
		or: [super shouldTranslate: anObject class: aClass]
]

{ #category : #accessing }
SSWODBCField >> sqlDialect [

	"Derive from the statement"

	^self statement sqlDialect
]

{ #category : #accessing }
SSWODBCField >> statement [

	"statement stores the SSWODBC...Statement to which this field relates"

	^statement
]

{ #category : #accessing }
SSWODBCField >> statement: anSSWODBCStatement [

	"statement stores the SSWODBC...Statement to which this field relates"

	statement := anSSWODBCStatement
]

{ #category : #accessing }
SSWODBCField >> value: anObject [

	"Special handling for function parameters: 
	Depending on the database type and function, the database may report an incorrect parameter type for a parameter field based on a function.
	e.g. YEAR(DATE_FIELD) may report DATE rather than INT type, or CONCAT(FIELD1, FIELD2) may have an insufficient buffer size for the parameter.
	Where this happens and causes an error, reconfigure the column based on the supplier parameter value, retry and mark the receiver for rebinding by its statement"

	[super value: anObject] on: Error do: 
		[ :exc |
		self column isFunctionParameter ifFalse: [exc pass].
		"Transcript cr; show: ('reconfigured <1s> size <2p>' expandMacrosWith: (ODBCTypes keyAtValue: column type) with: column length)."
		column configureToHold: anObject.
		self needsRebinding: true.
		column lengthC > buffer size ifTrue: [buffer := ExternalAddress gcallocate: ("2 raisedTo: 16" 65536 min: column lengthC)].
		"Transcript show: (' to <1s> size <2p>' expandMacrosWith: (ODBCTypes keyAtValue: column type) with: column length)."
		exc return: (super value: anObject)]
]
