"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWMSAccessDialect,
	#superclass : #SSWSQLDialect,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #constants }
SSWMSAccessDialect class >> dbmsName [

	^'ACCESS'
]

{ #category : #datatypes }
SSWMSAccessDialect >> boolean [

	^'YESNO'
]

{ #category : #testing }
SSWMSAccessDialect >> canDescribeParameters [

	^false
]

{ #category : #datatypes }
SSWMSAccessDialect >> date [

	"No explicit date type"

	^self datetime
]

{ #category : #datatypes }
SSWMSAccessDialect >> datetimeWithResolution [

	"Not supported"

	^self datetime
]

{ #category : #constants }
SSWMSAccessDialect >> defaultMaxColumnNameLength [

	^64
]

{ #category : #constants }
SSWMSAccessDialect >> defaultMaxTableNameLength [

	^64
]

{ #category : #constants }
SSWMSAccessDialect >> dialectSpecificFunctions [

	^Dictionary new

		"Conversion functions"
		at: #asInteger put: 'ROUND(%1,0)' asSQLFunctionIntegerResult;

		"Numeric functions"
		at: #\\ put: '(%1 MOD %2)' asSQLFunctionIntegerResult;

		"String functions"
		at: #, put: '(%1 + %2)' asSQLFunction;
		at: #midString:from: put: 'MID(%1,%3,%2)' asSQLFunction;
		at: #asciiValue put: 'ASC(%1)' asSQLFunctionIntegerResult;
		at: #leftString: put: 'LEFT(%1,%2)' asSQLFunction;
		at: #rightString: put: 'RIGHT(%1,%2)' asSQLFunction;
		
		"Date functions"
		at: #addDays: put: 'DATEADD(''d'',%2,%1)' asSQLFunction;
		at: #addMonths: put: 'DATEADD(''m'',%2,%1)' asSQLFunction;
		at: #addYears: put: 'DATEADD(''yyyy'',%2,%1)' asSQLFunction;
		at: #dayOfMonth put: 'DATEPART(''d'',%1)' asSQLFunctionIntegerResult;
		at: #monthIndex put: 'DATEPART(''m'',%1)' asSQLFunctionIntegerResult;
		at: #year put: 'DATEPART(''yyyy'',%1)' asSQLFunctionIntegerResult;

		"Logical functions"
		at: #ifNil: put: 'IIF(ISNULL(%1),%2,%1)' asSQLFunction;
		at: #ifNull: put: 'IIF(ISNULL(%1),%2,%1)' asSQLFunction;
		at: #ifNull:ifNotNull: put: ('IIF(ISNULL(%1),%2,%3)' asSQLFunction resultParamIndex: 2);
		at: #then:else: put: ('IIF(%1,%2,%3)' asSQLFunction resultParamIndex: 2);

		yourself
]

{ #category : #datatypes }
SSWMSAccessDialect >> longText [

	^'LONGTEXT'
]

{ #category : #constants }
SSWMSAccessDialect >> maxAllocatedStatements [

	"Access 2000 (v9.0.2720, driver 4.00.4403.02) seems to slowdown around 120 allocated statements"

	"Leave some headroom"
	^100
]

{ #category : #constants }
SSWMSAccessDialect >> maxDateTimeResolution [

	^0
]

{ #category : #maintenance }
SSWMSAccessDialect >> renameTableNamed: oldName to: newName in: anSSWReStore [

	anSSWReStore 
		executeSQLFrom: [ :stream | stream nextPutAll: 'SELECT * INTO '; nextPutIdentifier: newName; nextPutAll: ' FROM '; nextPutIdentifier: oldName];
		executeSQLFrom: [ :stream | stream nextPutAll: 'DROP TABLE '; nextPutIdentifier: oldName]
]

{ #category : #testing }
SSWMSAccessDialect >> shouldMapEmptyStringsToNil [

	"Return whether empty Strings should be mapped to nil before storage in the database.
	This can be useful for databases in which String fields default to 'Do not allow zero size' (usually this attribute cannot be set via ODBC/SQL)"

	^true
]

{ #category : #datatypes }
SSWMSAccessDialect >> time [

	"No explicit time type"

	^self datetime
]

{ #category : #constants }
SSWMSAccessDialect >> trueObject [

	^-1
]

{ #category : #constants }
SSWMSAccessDialect >> updateDelaySeconds [

	"Arrived at anecdotally... refresh SUnit tests fail with 4 seconds, pass with 5"

	^5
]
