"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBAbstractSubTable,
	#superclass : #SSWDBInheritedTable,
	#instVars : [
		'rootClass',
		'classCondition'
	],
	#category : #'SSW ReStore Tables'
}

{ #category : #'instance creation' }
SSWDBAbstractSubTable class >> forClass: aClass [

	"Overriden to set the rootClass"
	
	^self new
		instanceClass: aClass;
		rootClass: aClass persistencyRootClass;
		yourself
]

{ #category : #accessing }
SSWDBAbstractSubTable >> _classCondition [

	^SSWSQLCondition field: self classField equalTo: self instanceClass
]

{ #category : #accessing }
SSWDBAbstractSubTable >> classCondition [

	"classCondition stores an SSWSQLCondition(Collection) which is applied to all SELECTs 
	on the receiver table, to ensure only instances of the receiver's instanceClass are selected"
	
	^classCondition ifNil: [classCondition := self _classCondition]
]

{ #category : #evaluating }
SSWDBAbstractSubTable >> defaultName [

	"Overriden to use the rootClass name"
	
	^self sqlDialect transformClassName: self rootClass name
]

{ #category : #evaluating }
SSWDBAbstractSubTable >> forCreation [

	"The receiver should not CREATE TABLE (its persistent superclass will take care of this).
	Return nil"
		
	^nil
]

{ #category : #testing }
SSWDBAbstractSubTable >> hasStaticConditions [

	^true
]

{ #category : #testing }
SSWDBAbstractSubTable >> isRootTable [

	^false
]

{ #category : #evaluating }
SSWDBAbstractSubTable >> registerClass [

	"Objects created from this table are registered under the rootClass"

	^self rootClass
]

{ #category : #accessing }
SSWDBAbstractSubTable >> rootClass [

	"rootClass stores the Class which is the root of the persistent class hierarchy
	in which the receiver's instanceClass resides"
	
	^rootClass
]

{ #category : #accessing }
SSWDBAbstractSubTable >> rootClass: aClass [

	"rootClass stores the Class which is the root of the persistent class hierarchy
	in which the receiver's instanceClass resides"
	
	rootClass := aClass
]

{ #category : #evaluating }
SSWDBAbstractSubTable >> rootTable [

	"For a sub-table, the root table is the table of the rootClass"

	^self reStore tableForClass: self rootClass
]

{ #category : #evaluating }
SSWDBAbstractSubTable >> sqlAndStaticConditionsWith: anSQLConditionCollection [

	"Return the receiver's staticConditions ANDed with anSQLConditionCollection"
	
	"The receiver's staticConditions are redundant if there is a unique ID condition"
	^(anSQLConditionCollection anySatisfy: [ :cond | cond field = self idField and: [cond operator isEquality and: [cond value notNil]]]) 
		ifTrue: [anSQLConditionCollection]
		ifFalse: [self staticConditions sqlAnd: anSQLConditionCollection]
]

{ #category : #public }
SSWDBAbstractSubTable >> staticConditions [

	^self classCondition
]
