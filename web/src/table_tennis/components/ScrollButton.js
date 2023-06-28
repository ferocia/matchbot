import { IconButton } from "@chakra-ui/react";
import { ChevronLeftIcon, ChevronRightIcon } from "@chakra-ui/icons";

const ScrollButton = ({ buttonLocation, disabled, scroll, containerRef }) => {
  const buttonProps =
    buttonLocation === "left"
      ? {
          transform: "translateX(-125%)",
          onClick: () => scroll(-400, containerRef),
        }
      : {
          transform: "translateX(125%)",
          onClick: () => scroll(400, containerRef),
        };

  return (
    <IconButton
      {...buttonProps}
      variant="secondary"
      size="xs"
      borderWidth={1}
      borderRadius="full"
      boxShadow="lg"
      // _disabled={{ borderColor: colors.fg.subtle }}
      // _hover={{ bgColor: colors.bg.default }}
      disabled={disabled}
      icon={
        buttonLocation == "left" ? <ChevronLeftIcon /> : <ChevronRightIcon />
      }
    />
  );
};

export default ScrollButton;
