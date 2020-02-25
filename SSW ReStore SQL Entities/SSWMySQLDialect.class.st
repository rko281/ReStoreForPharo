"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWMySQLDialect,
	#superclass : #SSWSQLDialect,
	#category : #'SSW ReStore SQL Entities'
}

{ #category : #constants }
SSWMySQLDialect class >> dbmsName [

	^'MySQL'
]

{ #category : #maintenance }
SSWMySQLDialect >> alterField: aField table: aTable in: aReStore [

	aReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			nextPutIdentifier: aTable name;
			nextPutAll: ' MODIFY COLUMN '.
		aField writeSQLDefinitionOn: stream]
]

{ #category : #datatypes }
SSWMySQLDialect >> blobTypes [

	"Full use of MEDIUMBLOB and LONGBLOB will require increasing the default maxColumnBytes (unrealistically so for LONGBLOB)"

	^OrderedCollection new
		add: (255 "((2 raisedTo: 8) - 1)" -> 'TINYBLOB');
		add: (65535 "((2 raisedTo: 16) - 1)" -> 'BLOB');
		add: (16777215 "((2 raisedTo: 24) - 1)" -> 'MEDIUMBLOB');
		add: (4294967295 "((2 raisedTo: 32) - 1)" -> 'LONGBLOB');
		yourself
]

{ #category : #datatypes }
SSWMySQLDialect >> boolean [

	^'TINYINT'
]

{ #category : #constants }
SSWMySQLDialect >> defaultMaxColumnNameLength [

	^64
]

{ #category : #constants }
SSWMySQLDialect >> defaultMaxTableNameLength [

	^64
]

{ #category : #constants }
SSWMySQLDialect >> dialectSpecificFunctions [

	^Dictionary new

		"Conversion functions"
		at: #asInteger put: 'CAST(%1 AS UNSIGNED)' asSQLFunctionIntegerResult;

		"String functions"
		at: #, put: 'CONCAT(%1,%2)' asSQLFunction;
		at: #size put: 'CHAR_LENGTH(%1)' asSQLFunctionIntegerResult;
		at: #leftString: put: 'LEFT(%1,%2)' asSQLFunction;
		at: #rightString: put: 'RIGHT(%1,%2)' asSQLFunction;
		at: #asciiValue put: 'ASCII(%1)' asSQLFunctionIntegerResult;
		at: #indexOfSubCollection: put: 'LOCATE(%2,%1)' asSQLFunctionIntegerResult;
		at: #indexOfSubCollection:startingAt: put: 'LOCATE(%2,%1,%3)' asSQLFunctionIntegerResult;
		at: #replaceAllOccurencesOf:with: put: 'REPLACE(%1,%2,%3)' asSQLFunction;
		at: #reverse put: 'REVERSE(%1)' asSQLFunction;
		at: #replaceFrom:length:with: put: 'INSERT(%1,%2,%3,%4)' asSQLFunction;

		"Date functions"
		at: #addDays: put: 'DATE_ADD(%1, INTERVAL %2 DAY)' asSQLFunction;
		at: #addMonths: put: 'DATE_ADD(%1, INTERVAL %2 MONTH)' asSQLFunction;
		at: #addYears: put: 'DATE_ADD(%1, INTERVAL %2 YEAR)' asSQLFunction;
		at: #subtractDays: put: 'DATE_SUB(%1, INTERVAL %2 DAY)' asSQLFunction;
		at: #weekday put: 'DAYNAME(%1)' asSQLFunctionStringResult;
		at: #dayOfMonth put: 'DAYOFMONTH(%1)' asSQLFunctionIntegerResult;
		at: #day put: 'DAYOFYEAR(%1)' asSQLFunctionIntegerResult;
		at: #monthIndex put: 'MONTH(%1)' asSQLFunctionIntegerResult;
		at: #monthName put: 'MONTHNAME(%1)' asSQLFunctionStringResult ;
		at: #year put: 'YEAR(%1)' asSQLFunctionIntegerResult;

		yourself
]

{ #category : #constants }
SSWMySQLDialect >> maxVarchar [

	"MySQL's limit is technically 65535, but this is for an entire row.
	2KB should be safe enough that we don't exceed this, whilst being reasonably large"

	^2048
]

{ #category : #maintenance }
SSWMySQLDialect >> renameField: oldField to: newField in: aReStore [

	aReStore executeSQLFrom: 
		[ :stream | 
		stream 
			nextPutAll: 'ALTER TABLE ';
			nextPutIdentifier: newField table name;
			nextPutAll: ' CHANGE ';
			nextPutIdentifier: oldField name;
			space.
		newField writeSQLDefinitionOn: stream]
]

{ #category : #testing }
SSWMySQLDialect >> shouldMaskSuccessWithInfo [

	^true
]

{ #category : #testing }
SSWMySQLDialect >> supportsMultipleAddColumns [

	^true
]

{ #category : #datatypes }
SSWMySQLDialect >> unsizedStringTypes [

	"Full use of MEDIUMTEXT and LONGTEXT will require increasing the default maxColumnBytes (unrealistically so for LONGTEXT)"

	^OrderedCollection new
		add: (65535 "((2 raisedTo: 16) - 1)" -> 'TEXT');
		add: (16777215 "((2 raisedTo: 24) - 1)" -> 'MEDIUMTEXT');
		add: (4294967295 "((2 raisedTo: 32) - 1)" -> 'LONGTEXT');
		yourself
]
