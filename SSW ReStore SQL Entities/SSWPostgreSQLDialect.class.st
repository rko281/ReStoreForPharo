"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWPostgreSQLDialect,
	#superclass : #SSWSQLDialect,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #constants }
SSWPostgreSQLDialect class >> dbmsName [

	^'PostgreSQL'
]

{ #category : #maintenance }
SSWPostgreSQLDialect >> alterField: aField table: aTable in: aReStore [

	aReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			writeSQLFor: aTable;
			nextPutAll: ' ALTER COLUMN ';
			nextPutIdentifier: aField name;
			nextPutAll: ' TYPE '.
		aField targetClass writeSQLTypeOn: stream using: self]
]

{ #category : #datatypes }
SSWPostgreSQLDialect >> datetime [

	^'TIMESTAMP'
]

{ #category : #datatypes }
SSWPostgreSQLDialect >> datetimeWithResolution [

	^'TIMESTAMP(<1p>)'
]

{ #category : #constants }
SSWPostgreSQLDialect >> defaultDateTimeResolution [

	^6
]

{ #category : #constants }
SSWPostgreSQLDialect >> defaultMaxColumnNameLength [

	^63
]

{ #category : #constants }
SSWPostgreSQLDialect >> defaultMaxTableNameLength [

	^63
]

{ #category : #constants }
SSWPostgreSQLDialect >> defaultStandardNamespace [

	^'public'
]

{ #category : #constants }
SSWPostgreSQLDialect >> dialectSpecificFunctions [

	^Dictionary new

		"String functions"
		at: #size put: 'CHAR_LENGTH(%1)' asSQLFunctionIntegerResult;
		at: #asciiValue put: 'ASCII(%1)' asSQLFunctionIntegerResult;
		at: #indexOfSubCollection: put: 'POSITION(%2,%1)' asSQLFunctionIntegerResult;

		"Date functions"
		at: #dayOfMonth put: 'EXTRACT(DAY FROM %1)' asSQLFunctionIntegerResult;
		at: #monthIndex put: 'EXTRACT(MONTH FROM %1)' asSQLFunctionIntegerResult;
		at: #year put: 'EXTRACT(YEAR FROM %1)' asSQLFunctionIntegerResult;

		at: #ifNil: put: 'COALESCE(%1,%2)' asSQLFunction;
		at: #ifNull: put: 'COALESCE(%1,%2)' asSQLFunction;

		yourself
]

{ #category : #datatypes }
SSWPostgreSQLDialect >> double [

	^'DOUBLE PRECISION'
]

{ #category : #constants }
SSWPostgreSQLDialect >> identifierQuoteClose [

	^$"
]

{ #category : #constants }
SSWPostgreSQLDialect >> identifierQuoteOpen [

	^$"
]

{ #category : #constants }
SSWPostgreSQLDialect >> maxCharacter [

	"Technically 1GB, but limit it to something reasonable"

	^65535
]

{ #category : #maintenance }
SSWPostgreSQLDialect >> renameField: oldField to: newField in: aReStore [

	aReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			writeSQLFor: newField table;
			nextPutAll: ' RENAME ';
			nextPutIdentifier: oldField name;
			nextPutAll: ' TO ';
			nextPutIdentifier: newField name]
]

{ #category : #datatypes }
SSWPostgreSQLDialect >> unsizedBlob [

	^'bytea'
]
