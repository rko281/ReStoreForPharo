"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWSQLAggregatedOrderedSelectQuery,
	#superclass : #SSWSQLOrderedSelectQuery,
	#instVars : [
		'groupByFields'
	],
	#category : #'SSW ReStore SQL Queries'
}

{ #category : #accessing }
SSWSQLAggregatedOrderedSelectQuery >> groupByFields [
	^groupByFields
]

{ #category : #accessing }
SSWSQLAggregatedOrderedSelectQuery >> groupByFields: anObject [
	groupByFields := anObject
]

{ #category : #output }
SSWSQLAggregatedOrderedSelectQuery >> writeSQLOn: aStream [

	| aggConditions |
	
	self writeUnorderedSQLOn: aStream.
	
	aStream nextPutAll: ' GROUP BY '.
	self groupByFields do: [ :field | field writeSQLOn: aStream] separatedBy: [aStream nextPutAll: ', '].

	aggConditions := self conditions aggregatedConditions.
	aggConditions isEmpty ifFalse:
		[aStream nextPutAll: ' HAVING '.
		aggConditions writeSQLOn: aStream].

	self writeOrderingSQLOn: aStream
]

{ #category : #output }
SSWSQLAggregatedOrderedSelectQuery >> writeWhereClauseOn: aStream [

	"Overriden to factor aggregated conditions out to HAVING clause"
	
	| allConditions |
	
	allConditions := self conditions unaggregatedConditions.
	self tables do:
		[ :table |
		table hasStaticConditions ifTrue: [allConditions := table sqlAndStaticConditionsWith: allConditions]].
	
	allConditions isEmpty ifFalse:
		[aStream nextPutAll: ' WHERE '.
		allConditions writeSQLOn: aStream]

]
