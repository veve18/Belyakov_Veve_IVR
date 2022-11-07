const { Sequelize, DataTypes } = require("sequelize");
const sequelize = require("../utils/database");
const charityOrganisation = require("./charityOrganisation");

const AnimalShelterPost = sequelize.define(
	"AnimalShelterPost",
	{
		title: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		description: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		charityOrganisationId: {
			type: DataTypes.INTEGER,
			allowNull: false,
		},
		contact: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		image: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		city: {
			type: DataTypes.STRING,
			allowNull: true,
		},
		animal: {
			type: DataTypes.STRING,
			allowNull: false,
			defaultValue: "Кот",
		},
	},
	{
		timestamps: true,
	}
);

AnimalShelterPost.sync({
	alter: true,
});

module.exports = AnimalShelterPost;
