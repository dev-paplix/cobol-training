# Chapter 4: XML and JSON Processing in Modern COBOL

Modern enterprise systems rarely operate in isolation. Legacy backends must communicate with microservices, cloud platforms, and web interfaces exchanging data in **XML** and **JSON** formats.

This chapter demonstrates how GnuCOBOL handles these modern data interchange standards natively and reliably.

---

## 1. Native XML Generation (`XML GENERATE`)

GnuCOBOL provides built-in support for the standard COBOL `XML GENERATE` statement. This statement automatically serializes hierarchical COBOL group items into structured XML documents.

### How `XML GENERATE` Works
When `XML GENERATE` executes:
1. The compiler traverses the data structure hierarchy.
2. Group item names become opening and closing tags (`<CUSTOMER>`, `</CUSTOMER>`).
3. Elementary items become inner elements (`<NAME>JOHN DOE</NAME>`).
4. Values are trimmed of trailing spaces and encoded as UTF-8 XML.

### Syntax
```cobol
       XML GENERATE xml-target-buffer FROM source-group-item
           COUNT IN char-count-variable
           ON EXCEPTION
               DISPLAY "XML Generation Error: " XML-CODE
           NOT ON EXCEPTION
               DISPLAY "Generated " char-count-variable " bytes of XML"
       END-XML
```

### Complete Example
```cobol
       01  CUSTOMER-ORDER.
           05  ORDER-ID              PIC 9(6) VALUE 100452.
           05  CUSTOMER-INFO.
               10  CUST-NAME         PIC X(20) VALUE "Acme Logistics".
               10  ACCOUNT-NUM       PIC 9(8) VALUE 98765432.
           05  ORDER-TOTAL           PIC 9(5)V99 VALUE 1450.75.

       01  WS-XML-OUTPUT             PIC X(512) VALUE SPACES.
       01  WS-XML-LENGTH             PIC 9(4) BINARY VALUE 0.

      *======================================================*
       PROCEDURE DIVISION.
           XML GENERATE WS-XML-OUTPUT FROM CUSTOMER-ORDER
               COUNT IN WS-XML-LENGTH
               ON EXCEPTION
                   DISPLAY "XML generation failed."
               NOT ON EXCEPTION
                   DISPLAY "Successfully generated XML:"
                   DISPLAY WS-XML-OUTPUT(1:WS-XML-LENGTH)
           END-XML.
```

#### Generated XML Output
```xml
<CUSTOMER-ORDER><ORDER-ID>100452</ORDER-ID><CUSTOMER-INFO><CUST-NAME>Acme Logistics</CUST-NAME><ACCOUNT-NUM>98765432</ACCOUNT-NUM></CUSTOMER-INFO><ORDER-TOTAL>1450.75</ORDER-TOTAL></CUSTOMER-ORDER>
```

---

## 2. JSON Serialization & Deserialization

While some commercial mainframe compilers offer `JSON GENERATE` / `JSON PARSE`, modern open-source GnuCOBOL provides two ultra-reliable, portable techniques for handling JSON streams:
1. **Serialization**: Constructing clean JSON payloads using the `STRING` verb.
2. **Deserialization**: Parsing incoming JSON streams using `UNSTRING` and intrinsic string functions.

---

## 3. Serializing COBOL Records to JSON

The `STRING ... DELIMITED BY` statement allows dynamic, efficient concatenation of strings and numeric literals into a JSON payload.

### Pattern: Building a JSON Object
```cobol
       01  ORDER-DATA.
           05  ORD-ID            PIC 9(5) VALUE 50210.
           05  ORD-CLIENT        PIC X(20) VALUE "Global Tech Corp".
           05  ORD-AMOUNT        PIC 9(5)V99 VALUE 850.50.

       01  WS-FMT-AMOUNT         PIC ZZZZ9.99.
       01  WS-JSON-STRING        PIC X(512) VALUE SPACES.
       01  WS-JSON-PTR           PIC 9(4) VALUE 1.

      *======================================================*
       PROCEDURE DIVISION.
           MOVE ORD-AMOUNT TO WS-FMT-AMOUNT

           STRING
               '{"order_id": '
               FUNCTION TRIM(ORD-ID)
               ', "client": "'
               FUNCTION TRIM(ORD-CLIENT)
               '", "amount": '
               FUNCTION TRIM(WS-FMT-AMOUNT)
               '}'
               DELIMITED BY SIZE
               INTO WS-JSON-STRING
               WITH POINTER WS-JSON-PTR
           END-STRING.

           DISPLAY "JSON Payload: " WS-JSON-STRING.
```

#### Resulting JSON
```json
{"order_id": 50210, "client": "Global Tech Corp", "amount": 850.50}
```

---

## 4. Deserializing / Parsing JSON in COBOL

When receiving JSON from a web client or REST API, COBOL can parse key-value pairs using `UNSTRING` with delimiters or string position searching.

### Pattern: Extracting JSON Values with `UNSTRING`
Consider an incoming JSON stream:
```json
{"account": 10099, "status": "APPROVED", "credit": 5000.00}
```

We can extract values cleanly using delimiter logic:
```cobol
       01  RAW-JSON          PIC X(256) VALUE
           '{"account": 10099, "status": "APPROVED", "credit": 5000.00}'.

       01  WS-FIELD-NAME     PIC X(30).
       01  WS-VAL-ACCOUNT    PIC 9(5).
       01  WS-VAL-STATUS     PIC X(15).
       01  WS-VAL-CREDIT     PIC 9(6)V99.

       01  WS-PTR            PIC 9(4) VALUE 1.
       01  WS-DELIM          PIC X(10).

      *======================================================*
       PROCEDURE DIVISION.
      *> Find and extract account number
           UNSTRING RAW-JSON
               DELIMITED BY '"account": ' OR ' "account": '
               INTO WS-FIELD-NAME WS-VAL-ACCOUNT
           END-UNSTRING

      *> Find and extract status
           UNSTRING RAW-JSON
               DELIMITED BY '"status": "'
               INTO WS-FIELD-NAME WS-VAL-STATUS
           END-UNSTRING
      *> Remove trailing quote
           INSPECT WS-VAL-STATUS REPLACING ALL '"' BY ' '
```

### The Universal Tokenizer Pattern
For complex JSON payloads with multiple keys, the tokenization loop pattern inspects delimiters sequentially, matching key identifiers and converting the subsequent value to the appropriate COBOL target field.

---

## 5. Architectural Pipeline: JSON in, XML out

A standard enterprise pattern is a **Modernization Adapter**:
1. **Ingress**: Microservice submits HTTP POST with JSON body to a Linux wrapper.
2. **COBOL Logic**: COBOL program parses JSON fields into working-storage records, executes high-speed validation and calculation.
3. **Egress**: COBOL program generates an XML confirmation receipt using `XML GENERATE` to be archived or forwarded to enterprise messaging systems.

---

## 6. Summary Checklist for XML & JSON Processing

- [x] Use `XML GENERATE <target> FROM <record>` to turn COBOL group items into hierarchical XML.
- [x] Always check `ON EXCEPTION` when calling `XML GENERATE`.
- [x] Use `STRING ... WITH POINTER` and `FUNCTION TRIM` to construct clean, valid JSON strings.
- [x] Use `UNSTRING` or string inspection to parse incoming JSON payloads into strongly typed COBOL variables.

