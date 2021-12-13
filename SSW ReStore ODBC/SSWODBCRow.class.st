Class {
	#name : #SSWODBCRow,
	#superclass : #ODBCRow,
	#instVars : [
		'fieldMap'
	],
	#category : #'SSW ReStore ODBC'
}

{ #category : #initializing }
SSWODBCRow >> deAliasQueryFieldsFor: aDBQueryTable [

	"The receiver is derived from a query containing the given SSWDBQueryTable as an alias for an actual SSWDBTable.
	To allow field lookup by the original SSWDBTable, initialize the field map based on the original, non-aliased, fields"

	fieldMap := Dictionary new: columns size.
	1 to: columns size do: [ :index | (columns at: index) field ifNotNil: [ :field | field table == aDBQueryTable ifTrue: [fieldMap at: field field put: (contents at: index)]]]
]

{ #category : #initializing }
SSWODBCRow >> initializeFromBuffer: anSSWODBCBuffer [

	columns := anSSWODBCBuffer columns.
	contents := anSSWODBCBuffer objects.
	status := anSSWODBCBuffer status.

	"For smaller numbers of columns (<=12, arrived at experimentally) it's more efficient to avoid the fieldMap creation (see atField:ifAbsent:)"
	columns size > 12 ifTrue: 
		[fieldMap := Dictionary new: columns size.
		1 to: columns size do: [ :index | (columns at: index) field ifNotNil: [ :field | fieldMap at: field put: (contents at: index)]]]
]

{ #category : #accessing }
SSWODBCRow >> lookupField: aField [

	^fieldMap isNil 
		ifTrue: [1 to: columns size do: [ :index | (columns at: index) field = aField ifTrue: [^contents at: index]]. nil]
		ifFalse: [fieldMap at: aField ifAbsent: [nil]]
]
