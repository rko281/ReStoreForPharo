"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #TypeTest,
	#superclass : #Object,
	#instVars : [
		'char',
		'varchar',
		'medText',
		'largeText',
		'unsizedText',
		'integer',
		'float',
		'decimal',
		'date',
		'time',
		'datetime',
		'timeWithMilliseconds',
		'datetimeWithMilliseconds',
		'trueBoolean',
		'falseBoolean'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
TypeTest class >> reStoreDefinition [

	^super reStoreDefinition
		define: #char as: (String fixedSize: 50);
		define: #varchar as: (String maxSize: 250);
		define: #medText as: (String maxSize: 2000);
		define: #largeText as: (String maxSize: 5000);
		define: #unsizedText as: String;
		define: #integer as: Integer;
		define: #float as: Float;
		define: #decimal as: (ScaledDecimal withPrecision: 20 scale: 4);
		define: #date as: Date;
		define: #time as: Time;
		define: #datetime as: DateAndTime;
		define: #datetimeWithMilliseconds as: DateAndTime withMillisecondResolution;
		define: #trueBoolean as: Boolean;
		define: #falseBoolean as: Boolean;
		yourself
]

{ #category : #accessing }
TypeTest >> char [
	"Private - Answer the value of the receiver's ''char'' instance variable."

	^char
]

{ #category : #accessing }
TypeTest >> char: anObject [
	"Private - Set the value of the receiver's ''char'' instance variable to the argument, anObject."

	char := anObject
]

{ #category : #accessing }
TypeTest >> date [
	"Private - Answer the value of the receiver's ''date'' instance variable."

	^date
]

{ #category : #accessing }
TypeTest >> date: anObject [
	"Private - Set the value of the receiver's ''date'' instance variable to the argument, anObject."

	date := anObject
]

{ #category : #accessing }
TypeTest >> datetime [
	"Private - Answer the value of the receiver's ''datetime'' instance variable."

	^datetime
]

{ #category : #accessing }
TypeTest >> datetime: anObject [
	"Private - Set the value of the receiver's ''datetime'' instance variable to the argument, anObject."

	datetime := anObject
]

{ #category : #accessing }
TypeTest >> datetimeWithMilliseconds [
	^datetimeWithMilliseconds
]

{ #category : #accessing }
TypeTest >> datetimeWithMilliseconds: anObject [
	datetimeWithMilliseconds := anObject
]

{ #category : #accessing }
TypeTest >> decimal [
	"Private - Answer the value of the receiver's ''decimal'' instance variable."

	^decimal
]

{ #category : #accessing }
TypeTest >> decimal: anObject [
	"Private - Set the value of the receiver's ''decimal'' instance variable to the argument, anObject."

	decimal := anObject
]

{ #category : #accessing }
TypeTest >> falseBoolean [
	"Private - Answer the value of the receiver's ''falseBoolean'' instance variable."

	^falseBoolean
]

{ #category : #accessing }
TypeTest >> falseBoolean: anObject [
	"Private - Set the value of the receiver's ''falseBoolean'' instance variable to the argument, anObject."

	falseBoolean := anObject
]

{ #category : #accessing }
TypeTest >> float [
	"Private - Answer the value of the receiver's ''float'' instance variable."

	^float
]

{ #category : #accessing }
TypeTest >> float: anObject [
	"Private - Set the value of the receiver's ''float'' instance variable to the argument, anObject."

	float := anObject
]

{ #category : #accessing }
TypeTest >> integer [
	"Private - Answer the value of the receiver's ''integer'' instance variable."

	^integer
]

{ #category : #accessing }
TypeTest >> integer: anObject [
	"Private - Set the value of the receiver's ''integer'' instance variable to the argument, anObject."

	integer := anObject
]

{ #category : #accessing }
TypeTest >> largeText [
	"Private - Answer the value of the receiver's ''largeText'' instance variable."

	^largeText
]

{ #category : #accessing }
TypeTest >> largeText: anObject [
	"Private - Set the value of the receiver's ''largeText'' instance variable to the argument, anObject."

	largeText := anObject
]

{ #category : #accessing }
TypeTest >> medText [
	"Private - Answer the value of the receiver's ''medText'' instance variable."

	^medText
]

{ #category : #accessing }
TypeTest >> medText: anObject [
	"Private - Set the value of the receiver's ''medText'' instance variable to the argument, anObject."

	medText := anObject
]

{ #category : #accessing }
TypeTest >> time [
	"Private - Answer the value of the receiver's ''time'' instance variable."

	^time
]

{ #category : #accessing }
TypeTest >> time: anObject [
	"Private - Set the value of the receiver's ''time'' instance variable to the argument, anObject."

	time := anObject
]

{ #category : #accessing }
TypeTest >> trueBoolean [
	"Private - Answer the value of the receiver's ''trueBoolean'' instance variable."

	^trueBoolean
]

{ #category : #accessing }
TypeTest >> trueBoolean: anObject [
	"Private - Set the value of the receiver's ''trueBoolean'' instance variable to the argument, anObject."

	trueBoolean := anObject
]

{ #category : #accessing }
TypeTest >> unsizedText [
	"Private - Answer the value of the receiver's ''unsizedText'' instance variable."

	^unsizedText
]

{ #category : #accessing }
TypeTest >> unsizedText: anObject [
	"Private - Set the value of the receiver's ''unsizedText'' instance variable to the argument, anObject."

	unsizedText := anObject
]

{ #category : #accessing }
TypeTest >> varchar [
	"Private - Answer the value of the receiver's ''varchar'' instance variable."

	^varchar
]

{ #category : #accessing }
TypeTest >> varchar: anObject [
	"Private - Set the value of the receiver's ''varchar'' instance variable to the argument, anObject."

	varchar := anObject
]
