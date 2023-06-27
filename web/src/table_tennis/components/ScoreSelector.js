import { useRef } from "react";
import { Button, HStack, Stack } from "@chakra-ui/react";
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

  return (
    <HStack py="5" minW="100%" position="relative">
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

      <HStack
        ref={ref}
        scrollBehavior="smooth"
        overflowX="hidden"
        spacing={4}
        minW="100%"
      >
        {[...Array(32).keys()].map((index) => (
          <Button
            variant="outline"
            isActive={score === index}
            key={index}
            value={index}
            onClick={handleClick}
          >
            {index}
          </Button>
        ))}
      </HStack>

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
    </HStack>
  );
};

export default ScoreSelector;
