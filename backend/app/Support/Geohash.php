<?php

namespace App\Support;

/** Geohash (base32) dan jarak haversine — tanpa ekstensi PostGIS. */
final class Geohash
{
    private const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

    public const CELL_PRECISION = 4;

    public static function encode(float $lat, float $lng, int $precision = 9): string
    {
        $latR = [-90.0, 90.0];
        $lngR = [-180.0, 180.0];
        $hash = '';
        $bit = 0;
        $ch = 0;
        $even = true;
        while (strlen($hash) < $precision) {
            $range = $even ? $lngR : $latR;
            $mid = ($range[0] + $range[1]) / 2;
            $v = $even ? $lng : $lat;
            if ($v >= $mid) {
                $ch |= 1 << (4 - $bit);
                $even ? $lngR[0] = $mid : $latR[0] = $mid;
            } else {
                $even ? $lngR[1] = $mid : $latR[1] = $mid;
            }
            $even = ! $even;
            if (++$bit === 5) {
                $hash .= self::BASE32[$ch];
                $bit = 0;
                $ch = 0;
            }
        }

        return $hash;
    }

    public static function isValidCell(string $cell): bool
    {
        return (bool) preg_match('/^['.self::BASE32.']{'.self::CELL_PRECISION.'}$/', $cell);
    }

    /** Jarak permukaan bumi dalam meter. */
    public static function distanceMeters(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $r = 6371008.8;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        return 2 * $r * asin(min(1, sqrt($a)));
    }
}
