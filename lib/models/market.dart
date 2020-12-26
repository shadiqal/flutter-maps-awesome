import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Market {
  final String idMarket, nama, alamat, gambar;
  final double rating;
  final LatLng position;
  Market(
      {this.idMarket,
      this.nama,
      this.alamat,
      this.gambar,
      this.rating,
      this.position});
}

List<Market> listMarket = [
  Market(
    idMarket: "89q112",
    nama: "Warung ibu darmi",
    alamat:
        "Jl. Wirawan 3, Cisaranten Kidul, Kec. Gedebage, Kota Bandung, Jawa Barat 40295",
    gambar: "assets/images/warung1.jpg",
    rating: 3,
    position: LatLng(-6.947670, 107.683397),
  ),
  Market(
    idMarket: "89q112",
    nama: "Warung dahaga",
    alamat:
        "Jl. Riung Purna II 20-4, Cisaranten Kidul, Kec. Gedebage, Kota Bandung, Jawa Barat 40295",
    gambar: "assets/images/warung2.jpg",
    rating: 3,
    position: LatLng(-6.946704, 107.683941),
  ),
  Market(
    idMarket: "89q112",
    nama: "Warung anugrah jaya",
    alamat:
        "Jl. Wirawan I 6-8, Cisaranten Kidul, Kec. Gedebage, Kota Bandung, Jawa Barat 40295",
    gambar: "assets/images/warung3.jpg",
    rating: 3,
    position: LatLng(-6.947216, 107.683299),
  ),
  Market(
    idMarket: "89q112",
    nama: "Warung biru",
    alamat:
        "Jl. Riung Purna XI 151, Cisaranten Kidul, Kec. Gedebage, Kota Bandung, Jawa Barat 40295",
    gambar: "assets/images/warung4.jpg",
    rating: 3,
    position: LatLng(-6.948030, 107.684594),
  ),
];
