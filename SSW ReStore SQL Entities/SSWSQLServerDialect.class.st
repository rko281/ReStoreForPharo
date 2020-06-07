"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLServerDialect,
	#superclass : #SSWSQLDialect,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #constants }
SSWSQLServerDialect class >> dbmsName [

	^'MICROSOFT SQL SERVER' 
]

{ #category : #datatypes }
SSWSQLServerDialect >> boolean [

	^'BIT'
]

{ #category : #constants }
SSWSQLServerDialect >> dateAndTimeFormat [

	"The format for DateAndTImes when expressed as Strings"

	^'yyyy-MM-dd HH:mm:ssfff'
]

{ #category : #datatypes }
SSWSQLServerDialect >> datetime [

	^'DATETIME2'
]

{ #category : #datatypes }
SSWSQLServerDialect >> datetimeWithResolution [

	^'DATETIME2(<1p>)'
]

{ #category : #constants }
SSWSQLServerDialect >> defaultMaxColumnNameLength [

	^128
]

{ #category : #constants }
SSWSQLServerDialect >> defaultMaxTableNameLength [

	^128
]

{ #category : #constants }
SSWSQLServerDialect >> defaultStandardNamespace [

	^'dbo'
]

{ #category : #constants }
SSWSQLServerDialect >> dialectSpecificFunctions [

	^Dictionary new

		"Numeric functions"
		at: #rounded put: 'ROUND(%1,0)' asSQLFunctionIntegerResult;

		"String functions"
		at: #, put: '(%1 + %2)' asSQLFunction;
		at: #leftString: put: 'LEFT(%1,%2)' asSQLFunction;
		at: #rightString: put: 'RIGHT(%1,%2)' asSQLFunction;
		at: #asciiValue put: 'ASCII(%1)' asSQLFunctionIntegerResult;
		at: #indexOfSubCollection: put: 'CHARINDEX(%2,%1)' asSQLFunctionIntegerResult;
		at: #midString:from: put: 'SUBSTRING(%1,%3,%2)' asSQLFunction;
		
		"Date functions"
		at: #addDays: put: 'DATEADD(''d'',%2,%1)' asSQLFunction;
		at: #addMonths: put: 'DATEADD(''m'',%2,%1)' asSQLFunction;
		at: #addYears: put: 'DATEADD(''yyyy'',%2,%1)' asSQLFunction;
		at: #dayOfMonth put: 'DAY(%1)' asSQLFunctionIntegerResult;
		at: #monthIndex put: 'MONTH(%1)' asSQLFunctionIntegerResult;
		at: #year put: 'YEAR(%1)'asSQLFunctionIntegerResult;

		"Logical functions"
		at: #ifNil: put: 'ISNULL(%1,%2)' asSQLFunction;
		at: #ifNull: put: 'ISNULL(%1,%2)' asSQLFunction;

		yourself
]

{ #category : #datatypes }
SSWSQLServerDialect >> double [

	^'DOUBLE PRECISION'
]

{ #category : #constants }
SSWSQLServerDialect >> identifierQuoteClose [

	"Square brackers are the standard for SQLServer"

	^$]
]

{ #category : #constants }
SSWSQLServerDialect >> identifierQuoteOpen [

	"Square brackers are the standard for SQLServer"

	^$[
]

{ #category : #datatypes }
SSWSQLServerDialect >> integer [

	^'INT'
]

{ #category : #constants }
SSWSQLServerDialect >> maxCharacter [

	^8000
]

{ #category : #maintenance }
SSWSQLServerDialect >> renameField: oldField to: newField in: aReStore [

	aReStore executeSQL: ('EXEC sp_rename ''<1s>.<2s>'', <3p>, ''COLUMN''' expandMacrosWith: newField table qualifiedName with: oldField name with: newField name)
]

{ #category : #maintenance }
SSWSQLServerDialect >> renameTable: oldTable to: newTable in: anSSWReStore [

	anSSWReStore executeSQL: ('EXEC sp_rename <1p>,<2p>' expandMacrosWith: oldTable qualifiedName with: newTable name)
]

{ #category : #testing }
SSWSQLServerDialect >> supportsImplicitTrueConditions [

	^false
]

{ #category : #datatypes }
SSWSQLServerDialect >> unsizedBlob [

	^'varbinary(max)'
]
