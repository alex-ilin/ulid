! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar kernel math namespaces random sequences system ;

IN: ulid

<PRIVATE

CONSTANT: encoding "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
CONSTANT: base 32
CONSTANT: 64-bits 0xFFFFFFFFFFFFFFFF

SYMBOL: last-time-string
SYMBOL: last-random-bits

: encode-bits ( n chars -- string )
    <iota> [ drop base /mod encoding nth ] "" collector-as [ each ] dip
    nip reverse! ;

: encode-random-bits ( n -- string )
    16 encode-bits ;

: encode-time ( timestamp -- string )
    timestamp>millis 10 encode-bits ;

: same-msec? ( -- ? )
    nano-count 1000 /i dup \ same-msec? get =
    [ drop t ] [ \ same-msec? set f ] if ;

PRIVATE>

ERROR: ulid-overflow ;

: ulid ( -- ulid )
    same-msec? [
        last-time-string get last-random-bits get 1 +
        dup 64-bits > [ ulid-overflow ] when
    ] [
        now encode-time dup last-time-string set
        80 random-bits
    ] if dup last-random-bits set encode-random-bits append ;
