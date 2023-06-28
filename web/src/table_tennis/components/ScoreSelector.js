import { useRef } from "react";
import { Button, HStack, Stack, useBreakpointValue } from "@chakra-ui/react";
import ScrollButton from "./ScrollButton";

const ScoreSelector = ({ score, dispatch, teamKey }) => {
  const ref = useRef();
  const handleClick = (event) => {
    dispatch({
      type: "score_selected",
      teamKey: teamKey,
      score: parseInt(event.target.value),
    });
  };
  const handleScroll = (scroll, containerRef) => {
    const { current: container } = containerRef;
    const newScrollLeft = container.scrollLeft + scroll;

    container.scrollTo({ left: newScrollLeft });
  };

  const showScrollButtons = useBreakpointValue({
    base: false,
    md: true,
    lg: true,
  });

  return (
    <HStack py="5" minW="100%" position="relative">
      {showScrollButtons && (
        <Stack
          position="absolute"
          top={0}
          bottom={0}
          left={0}
          justifyContent="center"
        >
          <ScrollButton
            buttonLocation="left"
            scroll={handleScroll}
            containerRef={ref}
          />
        </Stack>
      )}

      <HStack
        ref={ref}
        scrollBehavior="smooth"
        overflowX={showScrollButtons ? "hidden" : "auto"}
        spacing={4}
        minW="100%"
        borderRadius="md"
        border="1px"
        borderColor="gray.200"
        p={3}
      >
        {[...Array(32).keys()].map((index) => (
          <Button
            isActive={score === index}
            key={index}
            value={index}
            onClick={handleClick}
          >
            {index}
          </Button>
        ))}
      </HStack>

      {showScrollButtons && (
        <Stack
          position="absolute"
          top={0}
          bottom={0}
          right={0}
          justifyContent="center"
        >
          <ScrollButton
            buttonLocation="right"
            scroll={handleScroll}
            containerRef={ref}
          />
        </Stack>
      )}
    </HStack>
  );
};

export default ScoreSelector;
