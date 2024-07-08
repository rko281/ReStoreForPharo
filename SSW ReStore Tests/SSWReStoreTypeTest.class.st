"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreTypeTest',
	#superclass : 'SSWReStoreTest',
	#instVars : [
		'date',
		'time',
		'datetime',
		'typeTest'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'running' }
SSWReStoreTypeTest >> addClassesTo: aReStore [

	aReStore addClass: TypeTest
]

{ #category : 'running' }
SSWReStoreTypeTest >> createTestData [

	datetime := DateAndTime now withResolution: reStore sqlDialect maxDateTimeResolution.
	date := datetime asDate.
	time := datetime asTime.

	reStore beginTransaction.
	TypeTest new
		char: 'CHAR';
		varchar: 'VARCHAR';
		medText: ((String new: 2000) atAllPut: $M; yourself);
		largeText: ((String new: 5000) atAllPut: $L; yourself);
		unsizedText: ((String new: 6000) atAllPut: $U; yourself);

		tinyBlob: (ByteArray withAll: (0 to: 240));
		medBlob: ((ByteArray new: 2000) atAllPut: 200; yourself);
		largeBlob: ((ByteArray new: 5000) atAllPut: 220; yourself);
		unsizedBlob: ((ByteArray new: 6000) atAllPut: 240; yourself);

		integer: 123;
		largeInteger: 1234567890;
		float: 123.456;
		decimal: 12345.67891;

		date: date;
		time: time;
		datetime: datetime;
		datetimeWithMilliseconds: datetime;

		trueBoolean: true;
		falseBoolean: false;

		uuid: self uuid;

		storeIn: reStore.
	reStore commitTransaction.

	self readTypeTest
]

{ #category : 'running' }
SSWReStoreTypeTest >> readTypeTest [

	reStore simulateReconnect.
	typeTest := (TypeTest storedInstancesIn: reStore) first
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testANSI [

	"Test a String containing only ANSI characters"

	self testStrings: #[99 97 102 101] asAnsiString "cafe"
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testBytes [

	| bytes allBytes tiny med large id |

	bytes := ByteArray withAll: (0 to: 255).
	allBytes := bytes.
	(10000 / bytes size) rounded timesRepeat: [allBytes := allBytes, bytes].

	tiny := allBytes copyFrom: 1 to: 255.
	med := allBytes copyFrom: 1 to: 2000.
	large := allBytes copyFrom: 1 to: 5000.

	typeTest 
		tinyBlob: tiny;
		medBlob: med;
		largeBlob: large;
		unsizedBlob: allBytes;
		store.
	id := typeTest _id.

	reStore simulateReconnect.
	typeTest := (TypeTest storedInstancesIn: reStore) detect: [ :each | each _id = id].

	self assert: typeTest tinyBlob equals: tiny.
	self assert: typeTest medBlob equals: med.
	self assert: typeTest largeBlob equals: large.
	self assert: typeTest unsizedBlob equals: allBytes.

	"SQLServer can't query on binary columns"
	reStore sqlDialect class ~~ SSWSQLServerDialect ifTrue: 
		[self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each tinyBlob = tiny]) identicalTo: typeTest.
		self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each medBlob = med]) identicalTo: typeTest.
		self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each largeBlob = large]) identicalTo: typeTest.
		self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each unsizedBlob = allBytes]) identicalTo: typeTest]
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testDate [

	self assert: (typeTest date = date)
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testDateQuery [

	| t2 |

	reStore simulateReconnect.
	t2 := (TypeTest storedInstancesIn: reStore) detect: [ :each | each date = typeTest date] ifNone: [nil].
	self assert: t2 notNil.
	self assert: t2 time = typeTest time
]

{ #category : 'public' }
SSWReStoreTypeTest >> testDateTime [

	reStore sqlDialect defaultDateTimeResolution = 0
		ifTrue: [self assert: (typeTest datetime - datetime) abs <= 1 seconds "Allow for rounding"]
		ifFalse: [self assert: (typeTest datetime = (datetime withResolution: reStore sqlDialect defaultDateTimeResolution))]
]

{ #category : 'public' }
SSWReStoreTypeTest >> testDateTimeQuery [

	| t |

	reStore sqlDialect defaultDateTimeResolution = 0
		ifTrue: [t := (TypeTest storedInstancesIn: reStore) detect: [ :each | (each datetime > (datetime - 1 seconds)) & (each datetime < (datetime + 1 seconds))] ifNone: [nil] "Allow for rounding"]
		ifFalse: [t := (TypeTest storedInstancesIn: reStore) detect: [ :each | each datetime = (datetime withResolution: reStore sqlDialect defaultDateTimeResolution)] ifNone: [nil]].
	
	self assert: t notNil
]

{ #category : 'public' }
SSWReStoreTypeTest >> testDateTimeWithMilliseconds [

	reStore sqlDialect maxDateTimeResolution < 3 ifTrue: [^self].

	"Take account of rounding differences between image and sql dialect"
	self assert: ((typeTest datetimeWithMilliseconds - (datetime withResolution: 3)) <= 1 milliseconds)
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testDecimal [

	self assert: (typeTest decimal = 12345.6789s4)
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testExtendedANSI [

	"Test a String containing an extended ANSI character"

	"SQLite Native in Dolphin deals purely in UTF8"
	(self isDolphin and: [reStore sqlDialect class name = #SSWSQLiteNativeDialect]) ifTrue: [self skip].

	self testStrings: #[99 97 102 233] asAnsiString "café"
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testGeneral [

	self assert: typeTest char trimBlanks equals: 'CHAR'.
	self assert: typeTest varchar equals: 'VARCHAR'.
	self assert: typeTest medText equals: ((String new: 2000) atAllPut: $M; yourself).
	self assert: typeTest largeText equals: ((String new: 5000) atAllPut: $L; yourself).
	self assert: typeTest unsizedText equals: ((String new: 6000) atAllPut: $U; yourself).
	self assert: typeTest integer equals: 123.
	self assert: typeTest largeInteger equals: 1234567890.
	self assert: typeTest float equals: 123.456.
	self assert: typeTest trueBoolean equals: true.
	self assert: typeTest falseBoolean equals: false
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testIntegerRange [

	typeTest integer: reStore sqlDialect integerMaximum; store.
	self readTypeTest.
	self assert: typeTest integer = reStore sqlDialect integerMaximum.

	typeTest integer: reStore sqlDialect integerMinimum; store.
	self readTypeTest.
	self assert: typeTest integer = reStore sqlDialect integerMinimum.
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testLargeIntegerRange [

	typeTest largeInteger: reStore sqlDialect largeIntegerMaximum; store.
	self readTypeTest.
	self assert: typeTest largeInteger = reStore sqlDialect largeIntegerMaximum.

	typeTest largeInteger: reStore sqlDialect largeIntegerMinimum; store.
	self readTypeTest.
	self assert: typeTest largeInteger = reStore sqlDialect largeIntegerMinimum.
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testNullBoolean [

	"Verify a NULL returned in a Boolean field gives the configured nullBoolean object"

	"Verify true and false are unaffected by the nullBoolean setting"
	reStore sqlDialect nullBoolean: nil.
	self readTypeTest.
	self assert: typeTest trueBoolean equals: true.
	self assert: typeTest falseBoolean equals: false.

	reStore sqlDialect nullBoolean: false.
	self readTypeTest.
	self assert: typeTest trueBoolean equals: true.
	self assert: typeTest falseBoolean equals: false.

	typeTest trueBoolean: nil; store.

	"Current behaviour - nils may be returned from Boolean columns"
	reStore sqlDialect nullBoolean: nil.
	self readTypeTest.
	self assert: typeTest trueBoolean equals: nil.

	"Legacy behaviour - nil coerced to false"
	reStore sqlDialect nullBoolean: false.
	self readTypeTest.
	self assert: typeTest trueBoolean equals: false
]

{ #category : 'running' }
SSWReStoreTypeTest >> testStrings: aString [

	| id |

	typeTest 
		varchar: aString;
		medText: aString;
		largeText: aString;
		unsizedText: aString;
		store.
	id := typeTest _id.

	reStore simulateReconnect.
	typeTest := (TypeTest storedInstancesIn: reStore) detect: [ :each | each _id = id].

	self assert: typeTest varchar equals: aString.
	self assert: typeTest medText equals: aString.
	self assert: typeTest largeText equals: aString.
	self assert: typeTest unsizedText equals: aString.

	self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each varchar = aString]) identicalTo: typeTest.
	self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each medText = aString]) identicalTo: typeTest.
	self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each largeText = aString]) identicalTo: typeTest.

	"SQLServer can't compare on unsized text columns"
	reStore sqlDialect class ~~ SSWSQLServerDialect ifTrue: 
		[self assert: ((TypeTest storedInstancesIn: reStore) detect: [ :each | each unsizedText = aString]) identicalTo: typeTest]
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testTime [

	"Use difference of <= 1 second to take account of different roundings in image and db"
	self assert: (typeTest time asSeconds - time asSeconds) abs <= 1
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testTimeQuery [

	| t2 |

	reStore simulateReconnect.

	reStore sqlDialect defaultTimeResolution = 0 
		ifTrue: [t2 := (TypeTest storedInstancesIn: reStore) detect: [ :each | each time = time] ifNone: [nil]]
		ifFalse: [t2 := (TypeTest storedInstancesIn: reStore) detect: [ :each | each time = (time withResolution: reStore sqlDialect defaultTimeResolution)] ifNone: [nil]].
	self assert: t2 notNil.
	self assert: t2 date = typeTest date
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testUTF8_2 [

	"Test a String containing a 2-byte UTF8 character"

	self testStrings: (Utf8String fromByteArray: #[99 97 102 195 169]) "café"
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testUTF8_3 [

	"Test a String containing a 3-byte UTF8 character"

	self testStrings: (Utf8String fromByteArray: #[99 97 102 226 130 172]) "caf€"
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testUTF8_4 [

	"Test a String containing a 4-byte UTF8 character"

	self testStrings: (Utf8String fromByteArray: #[99 97 102 240 160 156 142]) "caf𠜎"
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testUTF8_mixed [

	"Test a String containing a mixture of UTF8 characters"

	self testStrings: (Utf8String fromByteArray: #[195 156 98 195 168 114 115 116 114 195 174 195 177 103 195 169]) "Übèrstrîñgé"
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testUUID [

	self assert: typeTest uuid equals: self uuid
]

{ #category : 'unit tests' }
SSWReStoreTypeTest >> testUUIDQuery [

	| t1 t2 |

	reStore simulateReconnect.
	t1 := (TypeTest storedInstancesIn: reStore) detect: [ :each | each uuid = self uuid] ifNone: [nil].
	self assert: t1 notNil.
	self assert: t1 uuid = self uuid.

	t2 := (TypeTest storedInstancesIn: reStore) detect: [ :each | each uuid = GUID newUnique] ifNone: [nil].
	self assert: t2 isNil
]

{ #category : 'constants' }
SSWReStoreTypeTest >> uuid [

	^GUID fromString: '{e8beea63-43db-41e6-99e4-f31a64abd779}'
]
