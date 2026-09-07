/*
 * cob_sqlite.c - High-Performance C Bridge between GnuCOBOL and SQLite3
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sqlite3.h>

static void cob_to_c_str(const char *src, char *dst, int max_src_len) {
    int len = 0;
    while (len < max_src_len && src[len] != '\0') {
        len++;
    }
    while (len > 0 && (src[len - 1] == ' ' || src[len - 1] == '\r' || src[len - 1] == '\n')) {
        len--;
    }
    if (len > 0) {
        memcpy(dst, src, len);
    }
    dst[len] = '\0';
}

int cob_sqlite_open(const char *filename, sqlite3 **db_out, int32_t *status_out) {
    char c_file[512];
    cob_to_c_str(filename, c_file, 512);
    *status_out = sqlite3_open(c_file, db_out);
    return *status_out;
}

int cob_sqlite_exec(sqlite3 **db_in, const char *sql, int32_t *status_out) {
    char c_sql[1024];
    char *err_msg = NULL;
    cob_to_c_str(sql, c_sql, 512);
    *status_out = sqlite3_exec(*db_in, c_sql, NULL, NULL, &err_msg);
    if (err_msg != NULL) {
        fprintf(stderr, "[cob_sqlite_exec error %d]: %s\nQuery: '%s'\n", *status_out, err_msg, c_sql);
        sqlite3_free(err_msg);
    }
    return *status_out;
}

int cob_sqlite_prepare(sqlite3 **db_in, const char *sql, sqlite3_stmt **stmt_out, int32_t *status_out) {
    char c_sql[1024];
    cob_to_c_str(sql, c_sql, 512);
    *status_out = sqlite3_prepare_v2(*db_in, c_sql, -1, stmt_out, NULL);
    return *status_out;
}

int cob_sqlite_step(sqlite3_stmt **stmt_in, int32_t *status_out) {
    if (stmt_in == NULL || *stmt_in == NULL) {
        *status_out = SQLITE_ERROR;
        return *status_out;
    }
    *status_out = sqlite3_step(*stmt_in);
    return *status_out;
}

int cob_sqlite_get_int(sqlite3_stmt **stmt_in, int col_idx, int32_t *int_out) {
    if (stmt_in != NULL && *stmt_in != NULL) {
        *int_out = (int32_t)sqlite3_column_int(*stmt_in, col_idx);
    } else {
        *int_out = 0;
    }
    return 0;
}

int cob_sqlite_get_double(sqlite3_stmt **stmt_in, int col_idx, double *dbl_out) {
    if (stmt_in != NULL && *stmt_in != NULL) {
        *dbl_out = sqlite3_column_double(*stmt_in, col_idx);
    } else {
        *dbl_out = 0.0;
    }
    return 0;
}

int cob_sqlite_get_text(sqlite3_stmt **stmt_in, int col_idx, char *dest, int max_len) {
    if (stmt_in != NULL && *stmt_in != NULL) {
        const unsigned char *text = sqlite3_column_text(*stmt_in, col_idx);
        int len = 0;
        if (text != NULL) {
            len = strlen((const char *)text);
            if (len > max_len) {
                len = max_len;
            }
            memcpy(dest, text, len);
        }
        if (len < max_len) {
            memset(dest + len, ' ', max_len - len);
        }
    } else {
        memset(dest, ' ', max_len);
    }
    return 0;
}

int cob_sqlite_finalize(sqlite3_stmt **stmt_in, int32_t *status_out) {
    if (stmt_in != NULL && *stmt_in != NULL) {
        *status_out = sqlite3_finalize(*stmt_in);
        *stmt_in = NULL;
    } else {
        *status_out = SQLITE_OK;
    }
    return *status_out;
}

int cob_sqlite_close(sqlite3 **db_in, int32_t *status_out) {
    if (db_in != NULL && *db_in != NULL) {
        *status_out = sqlite3_close(*db_in);
        *db_in = NULL;
    } else {
        *status_out = SQLITE_OK;
    }
    return *status_out;
}

