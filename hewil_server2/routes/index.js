var express = require("express");
var router = express.Router();

var animalShelterPost = require("../models/animalShelterPost");
var charityPost = require("../models/charityPost");

router.get("/", function (req, res, next) {
	res.render("index", { title: "Express" });
});

router.get("/charity_cities", async function (req, res, next) {
	try {
		const charityCities = await charityPost.findAll({
			attributes: ["city"],
			group: ["city"],
		});
		res.json(charityCities);
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.get("/animal_shelter_cities", async function (req, res, next) {
	try {
		const animalShelterCities = await animalShelterPost.findAll({
			attributes: ["city"],
			group: ["city"],
		});
		res.json(animalShelterCities);
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

router.get("/animal_shelter_animals", async function (req, res, next) {
	try {
		const animalShelterAnimals = await animalShelterPost.findAll({
			attributes: ["animal"],
			group: ["animal"],
		});
		res.json(animalShelterAnimals);
	} catch (error) {
		console.error(error);
		res.status(500).json({
			message: "Something went wrong",
		});
	}
});

module.exports = router;
