/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/**
 * File format description for carbon schema file
 */
namespace java org.apache.carbondata.format

/**
*	The types supported by Carbon Data.
*/
enum DataType {
	STRING = 0,
	SHORT = 1,
	INT = 2,
	LONG = 3,
	DOUBLE = 4,
	DECIMAL = 5,
	TIMESTAMP = 6,
	ARRAY = 20,
	STRUCT = 21,
}

/**
*	Encodings supported by Carbon Data.  Not all encodings are valid for all types.
*	Certain Encodings can be chained.
*/
enum Encoding{
	DICTIONARY = 0; // Identified that a column is dictionary encoded
	DELTA = 1;	// Identifies that a column delta encoded
	RLE = 2;		// Indetifies that a column is run length encoded
	INVERTED_INDEX = 3; // identifies that a column is encoded using inverted index, can be used only along with dictionary encoding
	BIT_PACKED = 4;	// identifies that a column is encoded using bit packing, can be used only along with dictionary encoding
	DIRECT_DICTIONARY = 5; // Identifies that a column is direct dictionary encoded
}


/**
* Description of a Column for both dimension and measure
*/
//TODO:where to put the CSV column name and carbon table column name mapping? should not keep in schema
struct ColumnSchema{ 
	1: required DataType data_type;
	/**
	* Name of the column. If it is a complex data type, we follow a naming rule grand_parent_column.parent_column.child_column
	* For Array types, two columns will be stored one for the array type and one for the primitive type with the name parent_column.value
	*/
	2: required string column_name;  //
	3: required string column_id;  // Unique ID for a column. if this is dimension, it is an unique ID that used in dictionary
	4: required bool columnar; // wether it is stored as columnar format or row format
	5: required list<Encoding> encoders; // List of encoders that are chained to encode the data for this column
	6: required bool dimension;  // Whether the column is a dimension or measure
	7: optional i32 column_group_id; // The group ID for column used for row format columns, where in columns in each group are chunked together.
	/**
	* Used when this column contains decimal data.
	*/
	8: optional i32 scale;
	9: optional i32 precision;
	
	/** Nested fields.  Since thrift does not support nested fields,
	* the nesting is flattened to a single list by a depth-first traversal.
	* The children count is used to construct the nested relationship.
	* This field is not set when the element is a primitive type
	*/
	10: optional i32 num_child;
	
	/** 
	* Used when this column is part of an aggregate table.
	*/
	11: optional string aggregate_function;

	12: optional binary default_value;
	
	13: optional map<string,string> columnProperties;
	
    /**
	* To specify the visibily of the column by default its false
	*/
	14: optional bool invisible;

	/**
	 * column reference id
	 */
	15: optional string columnReferenceId;	
	
}

/**
* Description of One Schema Change, contains list of added columns and deleted columns
*/
struct SchemaEvolutionEntry{
	1: required i64 time_stamp;
	2: optional list<ColumnSchema> added;
	3: optional list<ColumnSchema> removed;
}

/**
* History of schema evolution
*/
struct SchemaEvolution{
    1: required list<SchemaEvolutionEntry> schema_evolution_history;
}

/**
* The description of table schema
*/
struct TableSchema{
	1: required string table_id;  // ID used to
	2: required list<ColumnSchema> table_columns; // Columns in the table
	3: required SchemaEvolution schema_evolution; // History of schema evolution of this table
  4: optional map<string,string> tableProperties; // table properties configured bu the user
}

struct TableInfo{
	1: required TableSchema fact_table;
	2: required list<TableSchema> aggregate_table_list;
}
