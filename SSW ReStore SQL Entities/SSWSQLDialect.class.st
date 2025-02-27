"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWSQLDialect',
	#superclass : 'Object',
	#instVars : [
		'connection',
		'classNameTransformation',
		'instVarNameTransformation',
		'maxColumnNameLength',
		'maxTableNameLength',
		'sqlFunctions',
		'maxColumnBytes',
		'unsizedStringSize',
		'unsizedBlobSize',
		'standardNamespace',
		'nullBoolean'
	],
	#category : 'SSW ReStore SQL Entities',
	#package : 'SSW ReStore SQL Entities'
}

{ #category : 'constants' }
SSWSQLDialect class >> dbmsName [

	"Return the name of the database whose dialect is represented by the receiver.
	Should correlate with the result of DBConnection>>dbmsName (ignoring case)"

	^self subclassResponsibility
]

{ #category : 'constants' }
SSWSQLDialect class >> dbmsVersion [

	"Return the version of the database whose dialect is represented by the receiver.
	Should correlate with the result of DBConnection>>dbmsVersion (ignoring case).

	From MS ODBC docs: '
		The version is of the form ##.##.####, where the first two digits are the major version, the next two digits are the minor version, and the last four digits are the release version. 
		The driver must render the DBMS product version in this form but can also append the DBMS product-specific version. For example, '04.01.0000 Rdb 4.1'.

	For convenience this value may be a pattern - dialects can handle subtle differences with conditionals (referring to their connection for the version)"

	^'*'
]

{ #category : 'testing' }
SSWSQLDialect class >> isCompatibleWithConnection: aDBConnection [

	"Default implementation uses name and version.
	Subclasses with more sophisticated requirements may override"

	^(self dbmsName sameAs: aDBConnection dbmsName) and: [self dbmsVersion match: aDBConnection dbmsVersion]
]

{ #category : 'instance creation' }
SSWSQLDialect class >> new [

	^super new initialize
]

{ #category : 'instance creation' }
SSWSQLDialect class >> newFor: aDBConnection [

	^(self subclassFor: aDBConnection) new
		initializeFor: aDBConnection;
		yourself
]

{ #category : 'accessing' }
SSWSQLDialect class >> subclassFor: aDBConnection [

	"Return the correct subclass of the receiver to use for the given DBConnection"

	"Sort to prefer subclasses with specific version number over non version-specific subclasses"
	^(self allSubclasses asSortedCollection: [ :c1 :c2 | c1 dbmsVersion size >= c2 dbmsVersion size]) detect: [ :each | each isCompatibleWithConnection: aDBConnection] ifNone: ["Fallback" self]
]

{ #category : 'maintenance' }
SSWSQLDialect >> addFields: aCollection to: aTable in: anSSWReStore [

	"Add the given collection of Fields to their table in anSSWReStore's database"

	| stream |

	self supportsMultipleAddColumns
	ifTrue:
		[stream := self sqlWriteStream.
		stream 
			nextPutAll: 'ALTER TABLE ';
			writeSQLFor: aTable.
		aCollection 
			do: 
				[ :field | 
				stream nextPutAll: ' ADD '.
				field writeSQLDefinitionOn: stream]
			separatedBy: [stream nextPut: $,].
		anSSWReStore executeSQL: stream contents]
	ifFalse:
		[aCollection do:
			[ :field || innerStream |
			innerStream := self sqlWriteStream.
			innerStream 
				nextPutAll: 'ALTER TABLE ';
				writeSQLFor: aTable;
				nextPutAll: ' ADD '.
			field writeSQLDefinitionOn: innerStream.
			anSSWReStore executeSQL: innerStream contents]]
]

{ #category : 'maintenance' }
SSWSQLDialect >> alterField: aField table: aTable in: aReStore [

	aReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			writeSQLFor: aTable;
			nextPutAll: ' ALTER COLUMN '.
		aField writeSQLDefinitionOn: stream]
]

{ #category : 'helpers' }
SSWSQLDialect >> asIdentifier: aString [

	| stream |
	
	stream := self sqlWriteStream.
	stream nextPutIdentifier: aString.
	^stream contents
]

{ #category : 'datatypes' }
SSWSQLDialect >> blob [

	"unsizedBlobSize is used to determine the most appropriate column type (see unsizedBlobSize method comment)"

	^self blobTypeForSize: self unsizedBlobSize
]

{ #category : 'datatypes' }
SSWSQLDialect >> blobTypeForSize: anInteger [

	anInteger <= self maxColumnBytes ifTrue: 
		[(self blobTypes asSortedCollection: [ :assoc1 :assoc2 | assoc1 key <= assoc2 key]) do: [ :assoc | assoc key >= anInteger ifTrue: [^assoc value]]].

	self error: 'No Blob type found for size <1p> - consider increasing maxColumnBytes'
]

{ #category : 'datatypes' }
SSWSQLDialect >> blobTypes [

	"Return a collection of associations between the maximum size of an unsized ByteArray type (i.e. one whose type declaration does not include its size, c.f. varblob), and its name in this dialect.

	By default this just consists of the blob type - dialects with more blob types can extend as necessary"

	^OrderedCollection new
		add: (self unsizedBlobSize -> self unsizedBlob);
		yourself
]

{ #category : 'datatypes' }
SSWSQLDialect >> boolean [

	^'BOOLEAN'
]

{ #category : 'datatypes' }
SSWSQLDialect >> char [

	^'CHAR(<1p>)'
]

{ #category : 'accessing' }
SSWSQLDialect >> classNameTransformation [

	"classNmeTransformation stores a one-arg Block which is evaluated with a class name and should deliver an equivalent database name.
	Standard tranformation is (e.g.) CustomerOrder -> customer_order"

	^classNameTransformation
]

{ #category : 'accessing' }
SSWSQLDialect >> classNameTransformation: aBlock [

	"classNmeTransformation stores a one-arg Block which is evaluated with a class name and should deliver an equivalent database name.
	Standard tranformation is (e.g.) CustomerOrder -> customer_order"

	classNameTransformation := aBlock
]

{ #category : 'constants' }
SSWSQLDialect >> commonFunctions [

	"Return a mapping from Smalltalk method names to an equivalent 'common' SQL function.
	Common function are as defined in SQL-99 standards and are assumed to be supported by all dialects.

	Subclasses should NOT override this method but instead implement dialectSpecificFunctions with any additional functions they support.
	If subclasses support a common function differently (or do not support it at all) they should add this to dialectSpecificFunctions, returning the alternative definition (or nil)"

	^Dictionary new

		"Conversion functions"
		at: #asString put: 'CAST(%1 AS CHAR)' asSQLFunction;
		at: #asInteger put: 'CAST(%1 AS INTEGER)' asSQLFunctionIntegerResult;

		"Numeric functions"
		at: #+ put: '(%1 + %2)' asSQLFunction;
		at: #- put: '(%1 - %2)' asSQLFunction;
		at: #* put: '(%1 * %2)' asSQLFunction;
		at: #/ put: '(%1 / %2)' asSQLFunction;
		at: #\\ put: '(%1 %% %2)' asSQLFunctionIntegerResult;
		at: #between:and: put: '%1 BETWEEN %2 AND %3' asSQLFunctionBooleanResult;
		at: #abs put: 'ABS(%1)' asSQLFunction;
		at: #rounded put: 'ROUND(%1)' asSQLFunctionIntegerResult;
		"Integer bit manipulation functions (the logical role of these is handled directly)"
		at: #& put: '(%1 & %2)' asSQLFunction;
		at: #| put: '(%1 | %2)' asSQLFunction;
		
		"String functions"
		at: #size put: 'LEN(%1)' asSQLFunctionIntegerResult;
		at: #, put: '(%1 || %2)' asSQLFunction;
		at: #indexOfSubCollection: put: 'INSTR(%1,%2)' asSQLFunctionIntegerResult;
		at: #midString:from: put: 'SUBSTRING(%1 FROM %3 FOR %2)' asSQLFunction;
		at: #trimBlanks put: 'TRIM(%1)' asSQLFunction;
		at: #asUppercase put: 'UPPER(%1)' asSQLFunction;
		at: #asLowercase put: 'LOWER(%1)' asSQLFunction;

		"Aggregate functions"
		at: #count put: 'COUNT(%1)' asSQLFunctionIntegerResult beAggregateFunction;
		at: #sum put: 'SUM(%1)' asSQLFunction beAggregateFunction;
		at: #minimum put: 'MIN(%1)' asSQLFunction beAggregateFunction;
		at: #maximum put: 'MAX(%1)' asSQLFunction beAggregateFunction;
		at: #average put: 'AVG(%1)' asSQLFunction beAggregateFunction;

		"Logical functions"
		at: #ifNil: put: 'IFNULL(%1,%2)' asSQLFunction;
		at: #ifNull: put: 'IFNULL(%1,%2)' asSQLFunction;
		at: #ifNull:ifNotNull: put: ('CASE WHEN %1 IS NULL THEN %2 ELSE %3 END' asSQLFunction resultParamIndex: 2);
		at: #then:else: put: ('CASE WHEN %1 THEN %2 ELSE %3 END' asSQLFunction resultParamIndex: 2);

		yourself
]

{ #category : 'accessing' }
SSWSQLDialect >> connection [
	^connection
]

{ #category : 'accessing' }
SSWSQLDialect >> connection: anObject [
	connection := anObject
]

{ #category : 'datatypes' }
SSWSQLDialect >> date [

	^'DATE'
]

{ #category : 'datatypes' }
SSWSQLDialect >> datetime [

	^'DATETIME'
]

{ #category : 'datatypes' }
SSWSQLDialect >> datetimeWithResolution [

	"Parameter is resolution (0=seconds, 3=milliseconds etc.)"

	^'DATETIME(<1p>)'
]

{ #category : 'datatypes' }
SSWSQLDialect >> decimal [

	^'DECIMAL(<1p>,<2p>)'
]

{ #category : 'constants' }
SSWSQLDialect >> defaultClassNameTransformation [

	^[ :name | name sswInUnderscoreFormat]
]

{ #category : 'constants' }
SSWSQLDialect >> defaultCursorType [

	"Return the Symbol-ic name of the cursor type that will be used when creating statements for cursored results in this dialect. 
	The names are adopted from the Dolphin ODBC package:
		CursorTypes
			at: #static put: SQL_CURSOR_STATIC;
			at: #forwardOnly put: SQL_CURSOR_FORWARD_ONLY;
			at: #keysetDriven put: SQL_CURSOR_KEYSET_DRIVEN;
			at: #dynamic put: SQL_CURSOR_DYNAMIC;

	This is mostly relevant for ODBC connections since native connections don't generally support different cursor types.
	It is included in the main class since specifying a nil cursorType when executing a query is used to indicate no cursor is required - this is relevant to the native MySQL implementation"

	^#forwardOnly
]

{ #category : 'constants' }
SSWSQLDialect >> defaultDateTimeResolution [

	"0 = seconds, 3 = milliseconds etc."

	^0
]

{ #category : 'constants' }
SSWSQLDialect >> defaultInstVarNameTransformation [

	^[ :name | name sswInUnderscoreFormat]
]

{ #category : 'constants' }
SSWSQLDialect >> defaultMaxColumnBytes [

	"default value for maxColumnBytes - see that method's comment"
	
	^self connection defaultMaxColumnBytes
]

{ #category : 'constants' }
SSWSQLDialect >> defaultMaxColumnNameLength [

	"Return an appropriate/known value for when the connection is unable to determine"
	^self subclassResponsibility
]

{ #category : 'constants' }
SSWSQLDialect >> defaultMaxTableNameLength [

	"Return an appropriate/known value for when the connection is unable to determine"
	^self subclassResponsibility
]

{ #category : 'constants' }
SSWSQLDialect >> defaultNullBoolean [

	^nil
]

{ #category : 'constants' }
SSWSQLDialect >> defaultSQLFunctions [

	| allDefaults |

	allDefaults := Dictionary new.

	self commonFunctions keysAndValuesDo: [ :message :sql | allDefaults at: message put: sql].
	self dialectSpecificFunctions keysAndValuesDo: [ :message :sql | allDefaults at: message put: sql].
	self platformSpecificFunctions keysAndValuesDo: [ :message :sql | allDefaults at: message put: sql].

	^allDefaults
]

{ #category : 'constants' }
SSWSQLDialect >> defaultStandardNamespace [

	^nil
]

{ #category : 'public' }
SSWSQLDialect >> defaultTimeResolution [

	"0 = seconds, 3 = milliseconds etc."

	^self defaultDateTimeResolution
]

{ #category : 'constants' }
SSWSQLDialect >> defaultUnsizedBlobSize [

	"default value for unsizedBlobSize - see that method's comment"
	
	"Default to the maximum column bytes - 1 (for null terminator)"
	^self maxColumnBytes - 1
]

{ #category : 'constants' }
SSWSQLDialect >> defaultUnsizedStringSize [

	"default value for unsizedStringSize - see that method's comment"
	
	"Default to the maximum column bytes - 1 (for null terminator)"
	^self maxColumnBytes - 1
]

{ #category : 'constants' }
SSWSQLDialect >> dialectSpecificFunctions [

	"Return a mapping from Smalltalk method names to an equivalent SQL function supported by this dialect.
	Subclasses should reimplement as appropriate"

	^Dictionary new
]

{ #category : 'datatypes' }
SSWSQLDialect >> double [

	^'DOUBLE'
]

{ #category : 'maintenance' }
SSWSQLDialect >> dropColumnNamed: colString fromTable: anSSWDBTable in: anSSWReStore [

	anSSWReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			writeSQLFor: anSSWDBTable;
			nextPutAll: ' DROP COLUMN ';
			nextPutIdentifier: colString]
]

{ #category : 'datatypes' }
SSWSQLDialect >> float [

	^'FLOAT'
]

{ #category : 'constants' }
SSWSQLDialect >> identifierQuoteClose [

	"Return the closing character used to wrap identifiers in quotes.
	SQL standard is actually double quote char but in some dialects this requires specific config changes.
	Instead we use the backtick character which is widely supported by default, and override where necessary"

	^$`
]

{ #category : 'constants' }
SSWSQLDialect >> identifierQuoteOpen [

	"Return the opening character used to wrap identifiers in quotes.
	SQL standard is actually double quote char but in some dialects this requires specific config changes.
	Instead we use the backtick character which is widely supported by default, and override where necessary"

	^$`
]

{ #category : 'initializing' }
SSWSQLDialect >> initialize [

	self
		sqlFunctions: self defaultSQLFunctions;
		nullBoolean: self defaultNullBoolean;
		classNameTransformation: self defaultClassNameTransformation;
		instVarNameTransformation: self defaultInstVarNameTransformation
]

{ #category : 'initializing' }
SSWSQLDialect >> initializeFor: aDBConnection [

	self
		connection: aDBConnection;
		maxColumnBytes: self defaultMaxColumnBytes;
		unsizedStringSize: self defaultUnsizedStringSize;
		unsizedBlobSize: self defaultUnsizedBlobSize;
		maxColumnNameLength: (aDBConnection maxColumnNameLength ifNil: [self defaultMaxColumnNameLength]);
		maxTableNameLength: (aDBConnection maxTableNameLength ifNil: [self defaultMaxTableNameLength]);
		standardNamespace: self defaultStandardNamespace
]

{ #category : 'accessing' }
SSWSQLDialect >> instVarNameTransformation [

	"classNmeTransformation stores a one-arg Block which is evaluated with an instance variable name and should deliver an equivalent database name.
	Standard tranformation is (e.g.) customerOrder -> customer_order"

	^instVarNameTransformation
]

{ #category : 'accessing' }
SSWSQLDialect >> instVarNameTransformation: aBlock [

	"classNmeTransformation stores a one-arg Block which is evaluated with an instance variable name and should deliver an equivalent database name.
	Standard tranformation is (e.g.) customerOrder -> customer_order"

	instVarNameTransformation := aBlock
]

{ #category : 'datatypes' }
SSWSQLDialect >> integer [

	^'INTEGER'
]

{ #category : 'constants' }
SSWSQLDialect >> integerMaximum [

	"Typically 4 byte signed"

	^((2 ** 31) - 1)
]

{ #category : 'constants' }
SSWSQLDialect >> integerMinimum [

	"Typically 4 byte signed"

	^((2 ** 31) negated)
]

{ #category : 'datatypes' }
SSWSQLDialect >> largeInteger [

	^'BIGINT'
]

{ #category : 'constants' }
SSWSQLDialect >> largeIntegerMaximum [

	"Typically 8 byte signed"

	^((2 ** 63) - 1)
]

{ #category : 'constants' }
SSWSQLDialect >> largeIntegerMinimum [

	"Typically 8 byte signed"

	^((2 ** 63) negated)
]

{ #category : 'datatypes' }
SSWSQLDialect >> longText [

	^'TEXT'
]

{ #category : 'constants' }
SSWSQLDialect >> maxAllocatedStatements [

	"Return an Integer specifying the maximum number of ODBC statements that should be allocated. 
	If this number is exceeded, statements are automatically freed when closed.

	Default - no particular limit"

	^SmallInteger maximum
]

{ #category : 'constants' }
SSWSQLDialect >> maxChar [

	^self maxCharacter
]

{ #category : 'constants' }
SSWSQLDialect >> maxCharacter [

	^255
]

{ #category : 'accessing' }
SSWSQLDialect >> maxColumnBytes [

	"defaultMaxColumnBytes defines the default maximum size of a column in bytes; this is not really a dialect-specific attribute but its value affects the choice of String column type so we specify it here.

	The default is defined by the connection object; if a different size is needed you can set an appropriate value for your application following login.
	
	Also bear in mind that (depending on the driver) this value may be used when creating a buffer for each unsized column which is replicated.
	If you increase this value then consider specifying a maximum String size in your class spec methods to avoid unnecessarily large buffers"

	^maxColumnBytes
]

{ #category : 'accessing' }
SSWSQLDialect >> maxColumnBytes: anObject [
	maxColumnBytes := anObject
]

{ #category : 'accessing' }
SSWSQLDialect >> maxColumnNameLength [

	"Initialized from the DB on login but may be set to something else (lower!) if necessary"

	^maxColumnNameLength
]

{ #category : 'accessing' }
SSWSQLDialect >> maxColumnNameLength: anObject [
	maxColumnNameLength := anObject
]

{ #category : 'constants' }
SSWSQLDialect >> maxDateTimeResolution [

	"0 = seconds, 3 = milliseconds etc."

	^6
]

{ #category : 'accessing' }
SSWSQLDialect >> maxTableNameLength [

	"Initialized from the DB on login but may be set to something else (lower!) if necessary"

	^maxTableNameLength
]

{ #category : 'accessing' }
SSWSQLDialect >> maxTableNameLength: anObject [
	maxTableNameLength := anObject
]

{ #category : 'public' }
SSWSQLDialect >> maxTimeResolution [

	"0 = seconds, 3 = milliseconds etc."

	^self maxDateTimeResolution
]

{ #category : 'constants' }
SSWSQLDialect >> maxVarchar [

	^self maxCharacter
]

{ #category : 'accessing' }
SSWSQLDialect >> nullBoolean [

	"nullBoolean stores the object used when a NULL value is returned from a Boolean field.
	Historically, ReStore coerced any non-true value (including NULL) to false, however the current behaviour is to return nil instead.
	To use the legacy behaviour, set nullBoolean to false"

	^nullBoolean
]

{ #category : 'accessing' }
SSWSQLDialect >> nullBoolean: anObject [

	"nullBoolean stores the object used when a NULL value is returned from a Boolean field.
	Historically, ReStore coerced any non-true value (including NULL) to false, however the current behaviour is to return nil instead.
	To use the legacy behaviour, set nullBoolean to false"

	nullBoolean := anObject
]

{ #category : 'event handling' }
SSWSQLDialect >> onConnected: aConnection [

	"Sent to the dialect immediately after login"

	self postLoginScript ifNotNil: 
		[ :script | 
		aConnection evaluateAsTxn: [aConnection exec: script. true]]
]

{ #category : 'constants' }
SSWSQLDialect >> postLoginScript [

	"Return any SQL String which should be evaluated on each login for this dialect, or nil if none"

	^nil
]

{ #category : 'helpers' }
SSWSQLDialect >> printParameterPlaceholder: anInteger on: aStream [

	"Defer to the connection"
	self connection printParameterPlaceholder: anInteger on: aStream
]

{ #category : 'maintenance' }
SSWSQLDialect >> renameField: oldField to: newField in: aReStore [

	"Simple implementation for dialects with no explicit rename column support"

	| table definitionTable updator |

	table := newField table.
	definitionTable := table rootTable forCreation.

	"Add a new column with the new name"
	self addFields: (Array with: newField) to: definitionTable in: aReStore. 
		
	"Update all instances in DB so newInstVar column value = oldInstVar column value"
	updator := (newField accessor name, ':') asSymbol.
	(aReStore instancesOf: table instanceClass) modify: [ :each | each perform: updator with: (each perform: oldField accessor name)].

	"Drop the old column"
	self dropColumnNamed: oldField name fromTable: definitionTable in: aReStore
]

{ #category : 'maintenance' }
SSWSQLDialect >> renameTable: oldTable to: newTable in: anSSWReStore [

	anSSWReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			writeSQLFor: oldTable;
			nextPutAll: ' RENAME TO ';
			nextPutIdentifier: newTable name]
]

{ #category : 'testing' }
SSWSQLDialect >> shouldExpandNamespacedAllFields [

	"Return true if the all fields * pseudo-field should be expanded into a list of fields where the table has a namspace, i.e. namespace.table.field1, namespace.table.field2 etc. instead of namespace.table.*
	Needed to accomodate SQLite which gives an error with namespace.table.* in SELECT query"

	^false
]

{ #category : 'testing' }
SSWSQLDialect >> shouldMapEmptyStringsToNil [

	"Return whether empty Strings should be mapped to nil before storage in the database.
	This can be useful for databases in which default String fields to 'Do not allow zero size (usually this attribute cannot be set via ODBC/SQL)"

	^false
]

{ #category : 'accessing' }
SSWSQLDialect >> sqlFunctionFor: aMessageSelector [

	^self sqlFunctions at: aMessageSelector ifAbsent: [nil]
]

{ #category : 'accessing' }
SSWSQLDialect >> sqlFunctions [

	"sqlFunctions stores a mapping from Smalltalk method names (which may not actually be implemented!) to an equivalent SQL function.
	It is initialized from the various function methods in the constants category, however client code may add initial functions after login, e.g.

		at: #plusPercent: put: '%1 * (1 + (%2 / 100))'

	Also note that, since the dialect is created following login, these must be (re)set up after login"

	^sqlFunctions
]

{ #category : 'accessing' }
SSWSQLDialect >> sqlFunctions: aDictionary [

	"sqlFunctions stores a mapping from Smalltalk method names (which may not actually be implemented!) to an equivalent SQL function.
	It is initialized from the various function methods in the constants category, however client code may add initial functions after login, e.g.

		at: #plusPercent: put: '%1 * (1 + (%2 / 100))'

	Also note that, since the dialect is created following login, these must be (re)set up after login"

	sqlFunctions := aDictionary
]

{ #category : 'helpers' }
SSWSQLDialect >> sqlWriteStream [

	^SSWSQLWriteStream newIn: self
]

{ #category : 'accessing' }
SSWSQLDialect >> standardNamespace [

	"standardNamespace stores the namespace (schema/database) in which unqualified (without a namespace. prefix) table names exist.
	This is initialized to a default for this dialect - see defaultStandardNamespace - and may be nil where this is irrelevant/unnecessary"

	^standardNamespace
]

{ #category : 'accessing' }
SSWSQLDialect >> standardNamespace: aString [

	"standardNamespace stores the namespace (schema/database) in which unqualified (without a namespace. prefix) table names exist.
	This is initialized to a default for this dialect - see defaultStandardNamespace - and may be nil where this is irrelevant/unnecessary"

	standardNamespace := aString
]

{ #category : 'testing' }
SSWSQLDialect >> supportsDeleteWithJoin [

	"Answer whether this dialect supports DELETE queries featuring JOINs"

	^false
]

{ #category : 'testing' }
SSWSQLDialect >> supportsImplicitTrueConditions [

	"Does this dialect support implicit true conditions like IS_SOMETHING or does it require IS_SOMETHING = TRUE"

	^true
]

{ #category : 'testing' }
SSWSQLDialect >> supportsMultipleAddColumns [

	"Return whether this dialect supports multiple 'ADD [COLUMN]' clauses per ALTER TABLE statement (true)
	or whether each column to be added must be done in a separate ALTER TABLE (false)"

	^false
]

{ #category : 'datatypes' }
SSWSQLDialect >> time [

	^'TIME'
]

{ #category : 'public' }
SSWSQLDialect >> timeWithResolution [

	"Parameter is resolution (0=seconds, 3=milliseconds etc.)"

	^'TIME(<1p>)'
]

{ #category : 'helpers' }
SSWSQLDialect >> transformClassName: aSymbol [

	"Transform the given class name into a DB-style String appropriate/conventional for this dialect"

	^self classNameTransformation value: aSymbol
]

{ #category : 'helpers' }
SSWSQLDialect >> transformInstVarName: aSymbol [

	"Transform the given inst var name into a DB-style String appropriate/conventional for this dialect"

	^self instVarNameTransformation value: aSymbol
]

{ #category : 'initializing' }
SSWSQLDialect >> translateMessage: aSymbol toFunction: aSQLFunction [

	self sqlFunctions at: aSymbol put: aSQLFunction
]

{ #category : 'datatypes' }
SSWSQLDialect >> unsizedBlob [

	^'BLOB'
]

{ #category : 'accessing' }
SSWSQLDialect >> unsizedBlobSize [

	"unsizedBlobSize stores the size assumed for ByteArrays in persistent classes if no explicit size is given.
	Whilst not strictly an SQLDialect attribute it is specified here for its interplay with column type choice.

	An unsized ByteArray will use the smallest blob type which supports unsizedBlobSize bytes
	- this is useful for databases which have more than one unsized blob type, to ensure the most efficient type is used"

	^unsizedBlobSize
]

{ #category : 'accessing' }
SSWSQLDialect >> unsizedBlobSize: anInteger [

	unsizedBlobSize := anInteger.

	"Ensure we can actually handle ByteArrays of this size. +1 is to accomodate a null terminator"
	self maxColumnBytes: (self maxColumnBytes max: (self unsizedBlobSize + 1))
]

{ #category : 'datatypes' }
SSWSQLDialect >> unsizedString [

	"Unsized = only limited by the maximum column size.
	defaultStringSize is used to determine the most appropriate column type does not imply a limit unless <= maxVarchar (see defaultStringSize method comment)"

	^self unsizedStringSize <= self maxVarchar 
		ifTrue: [self varchar expandMacrosWith: self unsizedStringSize]
		ifFalse: [self unsizedStringTypeForSize: self unsizedStringSize]
]

{ #category : 'accessing' }
SSWSQLDialect >> unsizedStringSize [

	"unsizedStringSize stores the size assumed for Strings in persistent classes if no explicit size is given.
	Whilst not strictly an SQLDialect attribute it is specified here for its interplay with column type choice:

	If unsizedStringSize <= maxVarchar, an unsized string will use the varchar type with defaultStringSize.
	 - this is useful for DBs which have limitations on the use of their longtext type (e.g. Oracle7 only allows one LONG column per table)

	If unsizedStringSize > maxVarchar, an unsized string will use the smallest longText type which supports defaultStringSize characters.
	 - this is useful for databases which have more than one long text type, to ensure the most efficient type is used"

	^unsizedStringSize
]

{ #category : 'accessing' }
SSWSQLDialect >> unsizedStringSize: anInteger [

	unsizedStringSize := anInteger.

	"Ensure we can actually handle single-byte Strings of this size. +1 is to accomodate a null terminator"
	self maxColumnBytes: (self maxColumnBytes max: (self unsizedStringSize + 1))
]

{ #category : 'datatypes' }
SSWSQLDialect >> unsizedStringTypeForSize: anInteger [

	anInteger <= self maxColumnBytes ifTrue: 
		[(self unsizedStringTypes asSortedCollection: [ :assoc1 :assoc2 | assoc1 key <= assoc2 key]) do: [ :assoc | assoc key >= anInteger ifTrue: [^assoc value]]].

	self error: 'No String type found for size <1p> - consider increasing maxColumnBytes'
]

{ #category : 'datatypes' }
SSWSQLDialect >> unsizedStringTypes [

	"Return a collection of associations between the maximum size of an unsized String type (i.e. one whose type declaration does not include its size, c.f. varchar), and its name in this dialect.

	By default this just consists of the longText type - dialects with more String types can extend as necessary"

	^OrderedCollection new
		add: (self unsizedStringSize -> self longText);
		yourself
]

{ #category : 'constants' }
SSWSQLDialect >> updateDelaySeconds [

	"In some DBs, an update may not be immediately visible in other sessions. 
	Return the number of seconds to wait before expecting the update to be visible.
	This is primarily for SUnit purposes but may be useful elsewhere"

	^0
]

{ #category : 'datatypes' }
SSWSQLDialect >> uuid [

	^(self blobTypeForSize: 16) expandMacrosWith: 16
]

{ #category : 'datatypes' }
SSWSQLDialect >> varchar [

	^'VARCHAR(<1p>)'
]
