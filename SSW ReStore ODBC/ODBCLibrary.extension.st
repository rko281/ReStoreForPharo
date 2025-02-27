Extension { #name : 'ODBCLibrary' }

{ #category : '*SSW ReStore ODBC' }
ODBCLibrary >> sqlDescribeParam: anExternalHandle parameterNumber: columnInteger dataTypePtr: typeSWORD parameterSizePtr: precisionDWORD decimalDigitsPtr: scaleSWORD nullablePtr: nullableSWORD [ 
	"SQLRETURN SQLDescribeParam(  
	      SQLHSTMT        StatementHandle,  
	      SQLUSMALLINT    ParameterNumber,  
	      SQLSMALLINT *   DataTypePtr,  
	      SQLULEN *       ParameterSizePtr,  
	      SQLSMALLINT *   DecimalDigitsPtr,  
	      SQLSMALLINT *   NullablePtr);  "
	
	self ffiCall: #(SQLRETURN SQLDescribeParam (SQLHSTMT anExternalHandle, SQLUSMALLINT columnInteger, SQLSMALLINT * typeSWORD, SQLULEN * precisionDWORD, SQLSMALLINT * scaleSWORD, SQLSMALLINT * nullableSWORD))
]
