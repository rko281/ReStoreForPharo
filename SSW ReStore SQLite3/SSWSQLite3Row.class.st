Class {
	#name : #SSWSQLite3Row,
	#superclass : #SQLite3Row,
	#instVars : [
		'fieldMap'
	],
	#category : #'SSW ReStore SQLite3'
}

{ #category : #accessing }
SSWSQLite3Row >> atField: aField [

	^self atField: aField ifAbsent: [nil]

]

{ #category : #accessing }
SSWSQLite3Row >> atField: aField ifAbsent: aBlock [

	^fieldMap at: aField ifAbsent: aBlock
]

{ #category : #initializing }
SSWSQLite3Row >> createFieldMapFrom: aDBQuery [

	fieldMap := Dictionary new.
	columnNames with: values do: 
		[ :key :value |
		key isString ifTrue: [ fieldMap at: (aDBQuery fieldNamed: key) put: value ] ]
]

{ #category : #accessing }
SSWSQLite3Row >> fieldMap [
	^ fieldMap
]
