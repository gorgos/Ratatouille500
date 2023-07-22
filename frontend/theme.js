import { extendTheme } from "@chakra-ui/react";

const theme = extendTheme({
  styles: {
    global: {
      "html, body": {
        backgroundColor: "#171923", // replace with your color
        color: "#FFF", // Or any color you want.
      }
    }
  }
});

export default theme;
