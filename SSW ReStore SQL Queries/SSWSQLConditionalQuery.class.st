"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWSQLConditionalQuery,
	#superclass : #SSWSQLTableQuery,
	#instVars : [
		'conditions'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #accessing }
SSWSQLConditionalQuery >> conditions [

	"conditions stores an SQLConditionCollection which filters this query"
	
	^conditions
]

{ #category : #accessing }
SSWSQLConditionalQuery >> conditions: anSQLConditionCollection [

	"conditions stores an SQLConditionCollection which filters this query"
	
	conditions := anSQLConditionCollection
]

{ #category : #testing }
SSWSQLConditionalQuery >> hasConditions [

	^self conditions isEmpty not
]

{ #category : #evaluating }
SSWSQLConditionalQuery >> parameterisedFields [

	| parameterisedFields |

	parameterisedFields := OrderedCollection new.

	self conditions do:
		[ :condition |
		condition operator messageSelector = #includedIn:
			ifTrue: [(condition value occurrencesOf: SSWSQLQueryParameter) timesRepeat: [parameterisedFields add: condition field]]
			ifFalse: [(condition value == SSWSQLQueryParameter) ifTrue: [parameterisedFields add: condition field]]].

	^parameterisedFields
]

{ #category : #output }
SSWSQLConditionalQuery >> writeWhereClauseOn: aStream [

	"Write the SQL for the WHERE clause for the receiver's conditions on aStream.
	If no conditions, do nothing"
	
	| allConditions |
	
	allConditions := self conditions.
	self tables do:
		[ :table |
		table hasStaticConditions ifTrue: [allConditions := table sqlAndStaticConditionsWith: allConditions]].
	
	allConditions isEmpty ifFalse:
		[aStream nextPutAll: ' WHERE '.
		allConditions writeSQLOn: aStream]
]
