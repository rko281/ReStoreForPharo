Class {
	#name : 'SSWODBCColAttr',
	#superclass : 'ODBCColAttr',
	#instVars : [
		'field',
		'maxBoundBufferSize',
		'isFunctionParameter'
	],
	#category : 'SSW ReStore ODBC',
	#package : 'SSW ReStore ODBC'
}

{ #category : 'instance creation' }
SSWODBCColAttr class >> forString: aString [

	"Create an instance of the receiver which describes a column capable of holding aString"

	^self new
		length: aString size;
		precision: aString size;
		maxBoundBufferSize: aString byteSize;
		type: SQL_VARCHAR;
		yourself
]

{ #category : 'initializing' }
SSWODBCColAttr >> configureToHold: anObject [

	(anObject isKindOf: String) ifTrue: [^self configureToHoldString: anObject].
	anObject class = ByteArray ifTrue: [^self configureToHoldByteArray: anObject].

	"Set length to a value long enough to handle any remaining type"
	length := 256.

	(anObject isKindOf: Number) ifTrue: [^self configureToHoldNumber: anObject].
	(anObject == true or: [anObject == false]) ifTrue: [^sqlType := SQL_BIT].
	anObject class = Date ifTrue: [^sqlType := SQL_TYPE_DATE].
	anObject class = Time ifTrue: [^sqlType := SQL_TYPE_TIME].
	(anObject class = DateAndTime or: [anObject class name = #TimeStamp "avoid dependency on deprecated package"]) ifTrue: [^sqlType := SQL_TYPE_TIMESTAMP].
	anObject class = GUID ifTrue: [^sqlType := SQL_GUID].

	self error: 'unsupported class'
]

{ #category : 'initializing' }
SSWODBCColAttr >> configureToHoldByteArray: aByteArray [

	sqlType := SQL_LONGVARBINARY.
	length := aByteArray size
]

{ #category : 'initializing' }
SSWODBCColAttr >> configureToHoldNumber: aNumber [

	aNumber isInteger ifTrue:
		[^(aNumber between: -32768 and: 32767)
			ifTrue: [sqlType := SQL_SMALLINT]
			ifFalse: [sqlType := SQL_BIGINT]].

	(aNumber isFloat or: [aNumber isFraction]) ifTrue: [^sqlType := SQL_DOUBLE].

	aNumber class = ScaledDecimal ifTrue: 
		[precision := 64.
		scale := aNumber scale.
		^sqlType := SQL_DECIMAL].

	self error: 'unsupported numeric class'
]

{ #category : 'initializing' }
SSWODBCColAttr >> configureToHoldString: aString [

	sqlType := SQL_WLONGVARCHAR.
	length := aString size * 2
]

{ #category : 'copying' }
SSWODBCColAttr >> copyForFunction [

	^self copy
		isFunctionParameter: true;
		yourself
]

{ #category : 'acccessing' }
SSWODBCColAttr >> field [

	"field stores the SSWSQLField from a SELECT query 
	that gave rise to this column in the resut set"

	^field
]

{ #category : 'acccessing' }
SSWODBCColAttr >> field: anSSWSQLField [

	"field stores the SSWSQLField from a SELECT query 
	that gave rise to this column in the resut set"

	field := anSSWSQLField
]

{ #category : 'initializing' }
SSWODBCColAttr >> initialize [

	super initialize.
	self isFunctionParameter: false
]

{ #category : 'acccessing' }
SSWODBCColAttr >> isFunctionParameter [
	^isFunctionParameter
]

{ #category : 'acccessing' }
SSWODBCColAttr >> isFunctionParameter: anObject [
	isFunctionParameter := anObject
]

{ #category : 'acccessing' }
SSWODBCColAttr >> lengthC [

	"Override to utilise metadata from the field if available"

	| lengthC |

	"Workaround primarily for PostgreSQL which returns negative value for length of SQL_LONGVARBINARY columns"
	length negative
		ifTrue: [lengthC := self maxBoundBufferSize]
		ifFalse: [lengthC := super lengthC min: self maxBoundBufferSize].

	(self field isNil or: [self isFunctionParameter]) ifTrue: [^lengthC].

	(sqlType = SQL_LONGVARCHAR or: [sqlType = SQL_LONGVARBINARY]) ifTrue: 
		[lengthC := self maxBoundBufferSize.
		^self field targetClass dbMaxFieldSize
			ifNil: [lengthC]
			ifNotNil: [ :maxFieldSize | lengthC min: (maxFieldSize + (CTypesExtraBytes at: sqlType+TypeOffset))]].

	sqlType = SQL_WLONGVARCHAR ifTrue: 
		[lengthC := self maxBoundBufferSize.
		^self field targetClass dbMaxFieldSize
			ifNil: [lengthC]
			ifNotNil: [ :maxFieldSize | lengthC min: ((maxFieldSize * 2) + (CTypesExtraBytes at: sqlType+TypeOffset))]].

	^lengthC
]

{ #category : 'acccessing' }
SSWODBCColAttr >> maxBoundBufferSize [
	^maxBoundBufferSize
]

{ #category : 'acccessing' }
SSWODBCColAttr >> maxBoundBufferSize: anObject [
	maxBoundBufferSize := anObject
]

{ #category : 'initializing' }
SSWODBCColAttr >> postCreate [

	"Workaround primarily for SQLite which reports BLOB columns as SQL_BINARY - this is defined as
		'Binary data of fixed length n'
	...which is incorrect and gives a max length of 255.

	Since ReStore doesn't support a SQL_BINARY type we convert this to SQL_LONGVARBINARY and increase the length accordingly"
	sqlType = SQL_BINARY ifFalse: [^self].

	self 
		type: SQL_LONGVARBINARY;
		length: self maxBoundBufferSize
]

{ #category : 'initializing' }
SSWODBCColAttr >> precision [

	^precision max: 0
]

{ #category : 'acccessing' }
SSWODBCColAttr >> scale [ 
	^scale ifNil: [ 0 ]
]

{ #category : 'acccessing' }
SSWODBCColAttr >> type: anInteger [
	"Private - Set the sqlType instance variable to anInteger."

	(sqlType notNil and: [self isFunctionParameter not]) ifTrue: [self error: 'attempt to reconfigure column type'].
	super type: anInteger
]

{ #category : 'printing' }
SSWODBCColAttr >> writeSQLOn: aStream [

	aStream nextPutAll: self name
]
