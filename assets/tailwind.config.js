module.exports = {
  purge: [],
  theme: {
    extend: {
      spacing: {
        "128": "32rem",
      },
      fontFamily: {
        roboto: "Roboto",
      },
      boxShadow: {
        "white-sm": "0px 5px 10px -4px rgba(219, 219, 219, 0.75)",
        white: "0px 4px 10px 0px rgba(219,219,219,0.75)",
      },
      screens: {
        dark: { raw: "(prefers-color-scheme: dark)" },
      },
      colors: {
        "google-blue": "#4285f4",
        "rich-black": "#0b0b0b",
        silver: {
          100: "#E7E7E7",
          200: "#DFDFDF",
          300: "#D7D7D7",
          400: "#CFCFCF",
          500: "#C7C7C7",
          600: "#AAAAAA",
          700: "#8E8E8E",
          800: "#727272",
          900: "#555555",
        },
        sage: {
          100: "#E4E2D0",
          200: "#DAD8C1",
          300: "#D1CEB1",
          400: "#C8C5A1",
          500: "#bfbb91",
          600: "#B6B283",
          700: "#ADA873",
          800: "#979259",
          900: "#797547",
        },
        "erie-black": {
          100: "#DFDFDF",
          200: "#C0C0C0",
          300: "#A0A0A0",
          400: "#808080",
          500: "#616161",
          600: "#414141",
          700: "#222222",
          800: "#1F1F1F",
          900: "#151515",
        },
      },
    },
  },
  variants: {},
  plugins: [],
};
