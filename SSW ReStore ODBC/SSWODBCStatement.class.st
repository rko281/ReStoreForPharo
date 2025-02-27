Class {
	#name : 'SSWODBCStatement',
	#superclass : 'ODBCParameterizedStatement',
	#instVars : [
		'query',
		'numColumns',
		'cachedColumns',
		'cachedColumnsIndices'
	],
	#category : 'SSW ReStore ODBC',
	#package : 'SSW ReStore ODBC'
}

{ #category : 'operations' }
SSWODBCStatement >> close [

	super close.
	self parent shouldFreeStatementsOnClose ifTrue: [self free]
]

{ #category : 'operations' }
SSWODBCStatement >> closeAfter: aBlock [

	^[aBlock value: self] ensure: [self close]
]

{ #category : 'initializing' }
SSWODBCStatement >> cursoredFetch: aBoolean [

	"Always enabled"
]

{ #category : 'exceptions' }
SSWODBCStatement >> dbCheckException: anIntegerRetCode [

	"Overriden to revector to parent connection, which may mask certain 'errors' "
	
	^self parent dbCheckException: anIntegerRetCode from: self
]

{ #category : 'accessing' }
SSWODBCStatement >> describeCols: columnNumbers [ 

	"Intercept to set the fields used in the query.
	Also cache the results - in the common case, a statement is always asked for the same columns so we do this as simply/efficiently as possible"

	(cachedColumnsIndices notNil and: [cachedColumnsIndices = columnNumbers]) ifTrue: [^cachedColumns].

	cachedColumnsIndices := columnNumbers.
	^cachedColumns :=
		(super describeCols: columnNumbers) collect: 
			[ :colAttr |
			SSWODBCColAttr new
				columnNumber: colAttr columnNumber;
				name: colAttr name;
				type: colAttr type;
				length: colAttr length;
				precision: colAttr precision;
				scale: colAttr scale;
				field: (self query ifNotNil: [ :q | q fieldNamed: colAttr name]);
				maxBoundBufferSize: self sqlDialect maxColumnBytes;
				postCreate;
				yourself]
]

{ #category : 'accessing' }
SSWODBCStatement >> describeParam: anInteger [

	"Return an ODBCColAttr describing the parameter number anInteger in this query. 
	May not be supported by all DBs, in which case return nil"

	| parameterSize dataType decimalDigits nullable hStmt ret |

	self sqlDialect canDescribeParameters ifFalse: [^nil].

	isPrepared ifFalse: [self prepare].

	dataType := SQLSMALLINT new.
	parameterSize := SQLULEN new.
	decimalDigits := SQLSMALLINT new.
	nullable := SQLSMALLINT new.
	hStmt := self allocatedHandle.
	ret := ODBCLibrary default
				sqlDescribeParam: hStmt
				parameterNumber: anInteger
				dataTypePtr: dataType
				parameterSizePtr: parameterSize
				decimalDigitsPtr: decimalDigits
				nullablePtr: nullable.
	self dbCheckException: ret.

	^SSWODBCColAttr new
		type: dataType value;
		length: parameterSize value;
		maxBoundBufferSize: parameterSize value;
		precision: parameterSize value;
		scale: decimalDigits value;
		yourself
]

{ #category : 'operations' }
SSWODBCStatement >> exec [

	parent logStatementExec: self.

	self close.
	isPrepared
		ifFalse: [self prepare].
	paramCols notNil
		ifTrue: [self setValues].
	self parent 
		dbCheckException: (ODBCLibrary default sqlExecute: self allocatedHandle) from: self;
		postExec.
	executed := true
]

{ #category : 'operations' }
SSWODBCStatement >> exec: aString [

	"Immediate execution of raw SQL"

	self 
		paramCols: #();
		prepare: aString.

	self exec
]

{ #category : 'operations' }
SSWODBCStatement >> execQuery: anSQLQuery [

	| stream |

	self query: anSQLQuery.

	stream := self sqlDialect sqlWriteStream.
	anSQLQuery writeSQLOn: stream.
	self sqlString: stream contents.

	stream hasParameterizedFields ifTrue: 
		[paramCols := stream parameterizedColumnsFor: self.
		self values: stream parameterizedValues].

	self exec
]

{ #category : 'accessing' }
SSWODBCStatement >> numColumns [

	"Cache for reuse"

	^numColumns ifNil: [numColumns := super numColumns]
]

{ #category : 'accessing' }
SSWODBCStatement >> parameters [

	"Overriden to use SSWDBODBCFields; see superclass implementation for comment"

	^parameters ifNil: 
		[parameters := (paramCols collect: [:col | SSWODBCField newForCol: col statement: self]) asArray.
		self bindParams.
		parameters]
]

{ #category : 'accessing' }
SSWODBCStatement >> prepare [

	"Clear caches"
	numColumns := cachedColumnsIndices := cachedColumns := nil.

	^super prepare
]

{ #category : 'accessing' }
SSWODBCStatement >> query [

	"query stores the SSWSQLQuery which the statement is prepared to execute"

	^query
]

{ #category : 'accessing' }
SSWODBCStatement >> query: anSSWSQLQuery [

	"query stores the SSWSQLQuery which the statement is prepared to execute"

	query := anSSWSQLQuery
]

{ #category : 'operations' }
SSWODBCStatement >> readValuesFrom: aStream [

	| size index |

	size := self paramCols size.
	self values: (Array new: size).
	index := 1.

	[aStream atEnd or: [index > size]] whileFalse: 
		[values at: index put: aStream next.
		index := index + 1]
]

{ #category : 'operations' }
SSWODBCStatement >> rebindParameterAt: anInteger [

	| field buf column |

	field := self parameters at: anInteger.
	buf := field fieldBuf.
	column := field column.
	self dbCheckException: 
		(ODBCLibrary default
			sqlBindParameter: self allocatedHandle
			parameterNumber: anInteger
			inputOutputType: column parameterType
			valueType: column cType
			parameterType: column type
			columnSize: column precision
			decimalDigits: column scale
			parameterValuePtr: buf
			bufferLength: buf byteSize
			strLenOrIndPtr: field lengthBuf).

	field needsRebinding: false
]

{ #category : 'accessing' }
SSWODBCStatement >> results [
	"Answer a <DBResultSet> that manages the results for the receiver.
	The result set will cause the receiver to be lazily executed when
	any attempt is made to access its contents."

	^(self cursorType == #forwardOnly 
		ifTrue: [SSWODBCForwardOnlyResultSet]
		ifFalse: [SSWODBCResultSet]) statement: self
]

{ #category : 'accessing' }
SSWODBCStatement >> rowsAffected [

	"Return the number of rows affected by this statement.
	Assume this represents the end of interaction by this statement so also close the receiver"

	^self closeAfter: [ :stmt | stmt numRows]
]

{ #category : 'operations' }
SSWODBCStatement >> setValues [
	"Private - Copy object values to the bound fields for the parameters of the prepared SQL
	statement. On first receipt this will cause the parameter fields to be created and bound 	(via #parameters)."

	1 to: self parameters size do: [:i || param |
		(param := parameters at: i) value: (values at: i).
		param needsRebinding ifTrue: [self rebindParameterAt: i]]
]

{ #category : 'accessing' }
SSWODBCStatement >> sqlDialect [

	"Derive from the parent connection"

	^self parent sqlDialect
]

{ #category : 'accessing' }
SSWODBCStatement >> values: aCollection [

	super values: (aCollection collect: [ :each | each reStoreValue])
]

{ #category : 'operations' }
SSWODBCStatement >> writeDebugInfoOn: aStream [

	| readStream valuesStream sqlStream |

	(paramCols ifNil: [#()]) isEmpty ifTrue: [^aStream nextPutAll: self sqlString; nextPut: $;; cr].

	readStream := ReadStream on: self sqlString.
	valuesStream := ReadStream on: self values.
	sqlStream := self sqlDialect sqlWriteStream.

	[| nextChunk |
	nextChunk := self parent upToParameterPlaceholderOn: readStream.
	nextChunk isEmpty ifFalse: 
		[sqlStream nextPutAll: nextChunk.
		valuesStream atEnd ifFalse: [valuesStream next printOn: sqlStream]].
	readStream atEnd] whileFalse.

	aStream nextPutAll: sqlStream contents; nextPut: $;; cr
]
