#!/usr/bin/env python3

def clamp(low, x, high):
    return low if x < low else high if x > high else x

def unwrap(txt):
    return ' '.join(( s.strip() for s in txt.strip().splitlines() ))
